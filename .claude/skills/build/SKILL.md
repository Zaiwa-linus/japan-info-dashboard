---
name: build
description: プロジェクトのビルド手順ガイド。dbt モデルのビルドから Evidence のソース更新・ビルドまでの正しい実行順序と、よくあるエラーのトラブルシューティングを定義する。Evidence ビルド時のテーブル不在エラーやデータ更新が反映されない場合に使用する。
---

# ビルド手順ガイド

## 1. ビルドの実行順序（必須）

dbt と Evidence は別々の DuckDB 接続を使用するため、**以下の順序を厳守すること。**

```bash
# Step 1: dbt モデルをビルド（DuckDB にテーブルを作成）
cd dbt_project && uv run dbt run

# Step 2: Evidence のソースデータを更新（DuckDB からデータを読み込み）
cd evidence_app && npm run sources

# Step 3: Evidence をビルド（静的サイトを生成）
cd evidence_app && npm run build
```

### なぜこの順序が必要か

```
dbt run          → DuckDB ファイル (dbt_project/target/dev.duckdb) にテーブルを書き込む
npm run sources  → DuckDB ファイルからデータを読み取り、Evidence 内部キャッシュに保存する
npm run build    → Evidence 内部キャッシュを使って静的サイトを生成する
```

**Step 2 を飛ばすと、Evidence は古いキャッシュを参照するため、新しいテーブルが見つからずエラーになる。**

## 2. 開発時のコマンド

| 目的 | コマンド | 作業ディレクトリ |
|------|---------|-----------------|
| dbt モデルのビルド | `uv run dbt run` | `dbt_project/` |
| dbt テストの実行 | `uv run dbt test` | `dbt_project/` |
| Evidence ソース更新 | `npm run sources` | `evidence_app/` |
| Evidence 開発サーバー | `npm run dev` | `evidence_app/` |
| Evidence プロダクションビルド | `npm run build` | `evidence_app/` |
| Evidence ビルドのプレビュー | `npm run preview` | `evidence_app/` |

## 3. よくあるエラーと対処法

### 3.1 `Table with name mart_xxx does not exist!`

**原因:** dbt で新しい mart モデルを追加した後、Evidence のソース更新（`npm run sources`）を実行していない。

**対処:**

```bash
# 1. dbt モデルがビルドされているか確認
cd dbt_project && uv run dbt run

# 2. Evidence のソースを更新
cd evidence_app && npm run sources

# 3. 再ビルド
cd evidence_app && npm run build
```

### 3.2 新しいソースクエリファイルを追加したのにデータが反映されない

**原因:** `evidence_app/sources/japan_stats/` に新しい `.sql` ファイルを追加した後、`npm run sources` を実行していない。

**対処:** `npm run sources` を実行してソースデータを再読み込みする。

### 3.3 `Error in Chart: Dataset is empty`

**原因:** クエリは成功したが、条件に該当するデータが0件。データの内容やフィルタ条件を確認する。

## 4. 新しい mart をページに追加する際のチェックリスト

1. `dbt_project/models/marts/mart_xxx.sql` を作成
2. `dbt_project/models/marts/_mart_xxx.yml` を作成
3. `evidence_app/sources/japan_stats/mart_xxx.sql` を作成（内容: `select * from mart_xxx`）
4. `evidence_app/pages/xxx.md` を作成
5. **ビルド順序に従って実行:**
   - `cd dbt_project && uv run dbt run`
   - `cd evidence_app && npm run sources`
   - `cd evidence_app && npm run build`
