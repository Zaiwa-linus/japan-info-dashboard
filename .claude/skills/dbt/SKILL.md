---
name: dbt-model-management
description: dbt モデルの作成・管理ルール。staging / intermediate / marts 各層のファイル構成、命名規約、列名サフィックスのバリデーションを定義する。dbt モデルの新規作成・修正時に使用する。
---

# dbt モデル管理ガイド

本プロジェクトの dbt モデルは **Staging → Intermediate → Marts** の3層アーキテクチャで管理する。
各層のルールに従ってモデルを作成・修正すること。

---

## 1. Staging 層 (`dbt_project/models/staging/`)

ソースデータをそのまま取り込み、列名の統一と型変換のみを行う層。**ビジネスロジックは一切含めない。**

### 1.1 ファイル構成

| ファイル | 命名規則 | 説明 |
|---------|---------|------|
| SQL モデル | `stg_{データ名}.sql` | ソースからの SELECT + 列リネーム + 型キャスト |
| モデル YAML | `_stg_{データ名}.yml` | 各モデルごとに1ファイル作成（列定義・テスト） |
| ソース定義 | `sources.yml` | 全ソースの CSV パス定義（共通1ファイル） |

### 1.2 SQL の書き方

```sql
-- {統計名} - {テーブル説明}
-- 統計表ID: {ID}
-- description: data/{統計表ID}/description.md

with source as (
    select * from {{ source('estat', '{統計表ID}') }}
)

select
    "{元カラム名}_code" as {意味}_code,
    "{元カラム名}" as {意味}_name,
    ...
    "{元カラム:単位}" as unit_name,
    try_cast(value as double) as raw_value
from source
```

**必須ルール:**
- **冒頭コメントに `description: data/{統計表ID}/description.md` のパスを記載する**
- ソース内容をそのまま SELECT する（フィルタ・結合・集計はしない）
- `with source as (select * from ...)` パターンを使用する
- `try_cast` で安全に型変換する

### 1.3 列名サフィックスルール（必須）

staging 層のすべての列名は、以下のサフィックスまたは許可名のいずれかでなければならない。

| サフィックス | 用途 | 例 |
|-------------|------|-----|
| `_code` | 分類コード | `area_code`, `item_code`, `purpose_code` |
| `_name` | 分類名称 | `area_name`, `item_name`, `purpose_name` |
| `_value` | 数値（集計値以外） | `indicator_value` |
| `_day` | 日（1〜31） | `survey_day` |
| `_month` | 月（1〜12） | `survey_month` |
| `_year` | 年（西暦） | `survey_year` |
| `_fyear` | 年度（4月始まり） | `fiscal_fyear` |

**例外は一切なし。** すべての列名が上記サフィックスのいずれかで終わること。

- `unit` → `unit_name` にリネームする
- 汎用的な数値列は `raw_value`（整理前）や `{指標}_value` にリネームする

#### バリデーションの実行（必須）

staging モデルを作成・修正したら、**必ず** Python バリデーションスクリプトを実行すること。

```bash
# 全 staging モデルをチェック
uv run python .claude/skills/dbt/validate_column_suffixes.py

# 特定ファイルのみチェック
uv run python .claude/skills/dbt/validate_column_suffixes.py dbt_project/models/staging/stg_xxx.sql
```

**バリデーションが通らない場合、列名を修正してから次の工程に進むこと。**

### 1.4 モデル YAML の書き方

```yaml
version: 2

models:
  - name: stg_{データ名}
    description: "{統計名} - {説明}"
    columns:
      - name: {列名}
        description: "{列の説明}"
        tests:
          - accepted_values:
              values: [...]  # コード列・カテゴリ列には必ず設定
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

### 2.2 SQL 冒頭コメント（必須）

intermediate / marts の SQL ファイルは、冒頭5行以内に**モデルの責務**と**ユニークキー**を明示すること。

```sql
-- [責務] 4業態の月次販売データを統合し、月次データのみに絞り込む
-- [ユニークキー] area_code, store_type_name, time_code
-- [入力] stg_convenience_store_sales, stg_electronics_store_sales, ...
```

| 項目 | 説明 |
|------|------|
| `[責務]` | このモデルが「何をするか」を1文で記述 |
| `[ユニークキー]` | 出力テーブルの1行を一意に特定する列の組み合わせ |
| `[入力]` | ref で参照する上流モデル名（任意だが推奨） |

### 2.3 prep（前処理）

**ビジネスロジックを含まない**、データの構造的な変換に使用する。

用途:
- **指標の分解**: ソースに複数指標が結合されている場合に、特定の指標だけを抽出する
- **年度の結合**: 帳票が年度別に分かれている場合に UNION ALL で統合する
- **不要な集計行の除外**: 合計行・小計行など、分析に不要な行を除外する
- **型変換・コード抽出**: 年コードから年を抽出する等の機械的な変換

```sql
-- [責務] 2022年度と2023年度の調査データを統合する
-- [ユニークキー] area_code, survey_year
-- [入力] stg_survey_2022, stg_survey_2023

with fy2022 as (
    select * from {{ ref('stg_survey_2022') }}
),
fy2023 as (
    select * from {{ ref('stg_survey_2023') }}
)
select * from fy2022
union all
select * from fy2023
```

### 2.4 logic（ビジネスロジック）

ビジネス上の判断や分類を伴う変換に使用する。

用途:
- **カテゴリ分類**: CASE 文による目的別分類・地域分類の付与
- **フラグ付与**: 小計行かどうか、特定条件に該当するかのフラグ追加
- **複数ソースの結合**: 異なるステージングモデルの JOIN / UNION
- **マスタテーブルの作成**: コード→表示名のルックアップテーブル

```sql
-- [責務] 入国目的コードに目的カテゴリ・地域分類を付与し、集約行を除外する
-- [ユニークキー] purpose_code, nationality_code, year_code
-- [入力] int_prep_immigration

select
    *,
    case
        when purpose_code in ('100', '110') then '短期滞在'
        when purpose_code >= '160' then '特定活動'
    end as purpose_category_name
from {{ ref('int_prep_immigration') }}
```

### 2.4 命名規則

| ディレクトリ | SQL ファイル | YAML ファイル |
|-------------|-------------|--------------|
| `prep/` | `int_prep_{名前}.sql` | `_int_prep_{名前}.yml` |
| `logic/` | `int_{名前}.sql` | `_int_{名前}.yml` |

---

## 3. Marts 層 (`dbt_project/models/marts/`)

Evidence から直接参照される最終出力。**ワイドテーブル（横持ち）** を採用する。

### 3.1 ワイドテーブルの設計方針

- **行**: 都道府県 × 年月（または年）などのグレイン（粒度）
- **列**: 各指標を個別の列として展開

```sql
-- [責務] 4業態の月次販売データを都道府県×年月×業態のワイドテーブルに変換する
-- [ユニークキー] area_code, store_type_name, year_month
-- [入力] int_retail_sales

select
    area_code,
    area_name,
    year,
    month,
    year_month,
    max(case when indicator_name = '販売額' then value end) as sales_value,
    max(case when indicator_name = '店舗数' then value end) as store_count_value
from {{ ref('int_retail_sales') }}
group by area_code, area_name, year, month, year_month
```

### 3.2 ファイル構成

| ファイル | 命名規則 |
|---------|---------|
| SQL モデル | `mart_{テーマ名}.sql` |
| モデル YAML | `_mart_{テーマ名}.yml` |

### 3.3 マテリアライゼーション

marts 層は `dbt_project.yml` で `+materialized: table` に設定済み。
個別指定は不要。

---

## 4. モデル作成の全体フロー

1. **data/ にCSVと description.md を配置**（estat スキルで取得）
2. **sources.yml にソースを追加**
3. **staging モデルを作成**（SQL + YAML）
4. **サフィックスバリデーションを実行**
   ```bash
   uv run python .claude/skills/dbt/validate_column_suffixes.py
   ```
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
