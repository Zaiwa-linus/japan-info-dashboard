---
name: dbt-model-management
description: dbt モデルの作成・管理ルール。staging / intermediate / marts 各層のファイル構成、命名規約、列名サフィックスのバリデーションを定義する。dbt モデルの新規作成・修正時に使用する。
---

# dbt モデル管理ガイド

本プロジェクトの dbt モデルは **Staging → Intermediate → Marts** の3層アーキテクチャで管理する。
各層のルールに従ってモデルを作成・修正すること。

> サンプルコードは `.claude/skills/dbt/examples/` を参照。

---

## 1. Staging 層 (`dbt_project/models/staging/`)

ソースデータをそのまま取り込み、列名の統一と型変換のみを行う層。**ビジネスロジックは一切含めない。**

### 1.1 ファイル構成

| ファイル | 命名規則 | 説明 |
|---------|---------|------|
| SQL モデル | `stg_{データ名}.sql` | ソースからの SELECT + 列リネーム + 型キャスト |
| モデル YAML | `_stg_{データ名}.yml` | 各モデルごとに1ファイル作成（列定義・テスト） |
| ソース定義 | `sources.yml` | 全ソースの CSV パス定義（共通1ファイル） |

### 1.2 SQL の必須ルール

- **冒頭コメントに `description: data/{統計表ID}/description.md` のパスを記載する**
- ソース内容をそのまま SELECT する（フィルタ・結合・集計はしない）
- `with source as (select * from ...)` パターンを使用する
- `try_cast` で安全に型変換する

> SQL / YAML テンプレート → `examples/staging.md`

### 1.3 列名サフィックスルール（必須）

staging 層のすべての列名は、以下のサフィックスのいずれかで終わること。**例外は一切なし。**

| サフィックス | 用途 | 例 |
|-------------|------|-----|
| `_code` | 分類コード | `area_code`, `item_code` |
| `_name` | 分類名称 | `area_name`, `item_name` |
| `_value` | 数値（集計値以外） | `indicator_value`, `raw_value` |
| `_day` | 日（1〜31） | `survey_day` |
| `_month` | 月（1〜12） | `survey_month` |
| `_year` | 年（西暦） | `survey_year` |
| `_fyear` | 年度（4月始まり） | `fiscal_fyear` |
| `_period_raw_code` | 未整理の時間軸コード | `survey_period_raw_code` |
| `_period_raw_name` | 未整理の時間軸名称 | `survey_period_raw_name` |

- `unit` → `unit_name` にリネーム
- 時間軸が年度・年・月など混在する場合は `_period_raw_code` / `_period_raw_name` を使い、intermediate 層で変換する

#### バリデーションの実行（必須）

staging モデルを作成・修正したら、**必ず**バリデーションスクリプトを実行すること。通らない場合は修正してから次の工程に進む。

```bash
uv run python .claude/skills/dbt/validate_column_suffixes.py
```

---

## 2. Intermediate 層 (`dbt_project/models/intermediate/`)

staging のデータに対してフィルタ・結合・分類などの変換を行う層。
**`prep` と `logic` の2つのサブディレクトリに分けて管理する。**

### 2.1 ディレクトリ構成

```
intermediate/
├── prep/       # ビジネスロジックを含まない前処理
│   ├── int_prep_{名前}.sql
│   └── _int_prep_{名前}.yml
└── logic/      # ビジネスロジックを含む変換
    ├── int_{名前}.sql
    └── _int_{名前}.yml
```

### 2.2 ITM 設計ルール（必須）

Intermediate 層のモデルは **他のモデルやダッシュボードから流用される前提** で設計する。以下のルールを厳守すること。

> 各ルールの OK/NG コード例 → `examples/intermediate.md`

#### ルール1: NULL 値の完全排除

ITM の出力に **NULL 値は一切許容しない**。`WHERE ... IS NOT NULL` で除外するか `COALESCE` で埋めること。横持ち変換時の NULL も禁止（ルール3参照）。

#### ルール2: 指標区分をユニークキーに含めない

ユニークキーに **指標の種類（売上・利益・損失 等）を区分として持つことを禁止** する。指標が複数ある場合は **横持ち（ピボット）** にすること。

#### ルール3: 横持ち時のデータ期間不一致はモデルを分離する

横持ちにした結果、指標間でデータの存在期間が異なり NULL が発生する場合は、**モデル自体を分けること**。期間が揃う指標同士だけを1つの横持ちモデルにまとめる。

#### ルール4: P-key の値は MECE であること

ITM のユニークキー（P-key）に使う分類列は、**取り得る値が MECE（漏れなくダブりなく）** でなければならない。

- 分類の各値が **相互に排他的** で、かつ **全体を網羅** していること
- **NG**: 「男」「女」「男女」のように、集約値と内訳値が混在 → MECE でない
- **NG**: 「全国」「東京都」「大阪府」…のように、合計行と個別行が混在 → 同上

集約行（合計・小計）が含まれる場合は、`WHERE` で除外するか、別のモデルに分離すること。

#### ルール5: value 列は合計が意味をなすこと

ITM の `value` 列（数値列）は、**同一列内の値を合計したときに意味のある数値** でなければならない。

- 1つの value 列には **同じ単位・同じ意味の数値** のみを格納すること
- **NG**: 「発注数」と「売上高」を同じ `value` 列に縦持ち → 合計しても意味不明
- **NG**: 「人口」と「人口密度」を同じ列に持つ → 単位が異なり合計不可

異なる指標は **別の列に横持ち** するか、**別のモデルに分離** すること（ルール2・3も参照）。

#### ルール6: 月次データの日付型

月次データは **`DATE` 型（月初日固定）** で保持する。列名は `year_month` とする。

- `DATE` 型にすることでソート・フィルタ・日付関数・Evidence チャート軸すべてに対応できる
- 年のみのデータは `INTEGER` 型の `year` 列を使用する
- `year_month` は列名サフィックスルールの例外として許容する

### 2.3 SQL 冒頭コメント（必須）

intermediate / marts の SQL ファイルは、冒頭5行以内に**モデルの責務**と**ユニークキー**を明示すること。

| 項目 | 説明 |
|------|------|
| `[責務]` | このモデルが「何をするか」を1文で記述 |
| `[ユニークキー]` | 出力テーブルの1行を一意に特定する列の組み合わせ |
| `[入力]` | ref で参照する上流モデル名（任意だが推奨） |

### 2.4 prep（前処理）

**ビジネスロジックを含まない**、データの構造的な変換に使用する。

用途: 指標の分解 / 年度の結合（UNION ALL）/ 不要な集計行の除外 / 型変換・コード抽出

### 2.5 logic（ビジネスロジック）

ビジネス上の判断や分類を伴う変換に使用する。

用途: カテゴリ分類（CASE文）/ フラグ付与 / 複数ソースの結合 / マスタテーブルの作成

---

## 3. Marts 層 (`dbt_project/models/marts/`)

Evidence から直接参照される最終出力。**ワイドテーブル（横持ち）** を採用する。

- **行**: 都道府県 × 年月（または年）などのグレイン（粒度）
- **列**: 各指標を個別の列として展開
- ファイル命名: `mart_{テーマ名}.sql` / `_mart_{テーマ名}.yml`
- マテリアライゼーション: `dbt_project.yml` で `+materialized: table` 設定済み（個別指定不要）

> ワイドテーブルの SQL 例 → `examples/marts.md`

---

## 4. モデル作成の全体フロー

1. **data/ にCSVと description.md を配置**（estat スキルで取得）
2. **sources.yml にソースを追加**
3. **staging モデルを作成**（SQL + YAML）
4. **サフィックスバリデーションを実行**
5. **intermediate モデルを作成**（prep → logic の順）
6. **mart モデルを作成**（ワイドテーブル形式）
7. **dbt run & test で動作確認**
   ```bash
   cd dbt_project && uv run dbt run && uv run dbt test
   ```

---

## 5. 既存モデル構成の参考

### staging の例
- `stg_population.sql` → `_stg_population.yml`
- `stg_convenience_store_sales.sql` → `_stg_convenience_store_sales.yml`

### intermediate の例（現状は prep/logic 分離前）
- `int_retail_sales.sql` — 4業態の UNION（prep 相当）
- `int_immigration_by_purpose.sql` — カテゴリ分類（logic 相当）
- `int_master_household_indicator.sql` — マスタ作成（logic 相当）

### marts の例
- `mart_retail_sales.sql` — MAX/CASE によるワイドテーブル
- `mart_durable_goods.sql` — マスタ JOIN でワイド化
