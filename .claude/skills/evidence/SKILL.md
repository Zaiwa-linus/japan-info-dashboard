---
name: evidence
description: Evidence フレームワークの使い方ガイド。Evidence のページ作成、SQLクエリ記述、コンポーネント（チャート・テーブル・入力等）の利用、データソース設定、GitHub Pages へのデプロイ、Evidence-flavored Markdown 構文に関する作業時に使用する。
---

# Evidence の使い方

Evidence は SQL とマークダウンでデータダッシュボードを構築するオープンソースフレームワーク。

## このプロジェクトでの使い方

- Evidence のページは `evidence_app/pages/` ディレクトリに `.md` ファイルとして作成する
- SQL クエリはマークダウンのコードフェンス内に名前付きで記述する（DuckDB SQL 方言）
- データソースの設定は `evidence_app/sources/` 配下で行う
- dbt の Mart 層（`dbt_project/models/marts/`）で集計されたデータを Evidence から参照する
- GitHub Pages へのデプロイを前提とし、ベースパスの設定に注意すること

## クイックリファレンス

### 基本的なページ作成パターン

````markdown
---
title: ページタイトル
---

# タイトル

```sql my_query
select * from my_source.my_table
```

<LineChart data={my_query} x=date_column y=value_column />
````

### フィルタリングパターン

````markdown
```sql categories
select distinct category from my_source.my_table
```

<Dropdown data={categories} name=selected_category value=category />

```sql filtered_data
select * from my_source.my_table
where category = '${inputs.selected_category.value}'
```
````

### 主要 CLI コマンド

| コマンド | 用途 |
|---|---|
| `npm run dev` | 開発サーバー起動 |
| `npm run build` | プロダクションビルド |
| `npm run build:strict` | エラー時ビルド失敗 |
| `npm run sources` | データソース実行 |

## 詳細リファレンス

構文、コンポーネント一覧、データソース設定、デプロイ方法などの詳細は [reference.md](reference.md) を参照。

## 公式ドキュメント

- トップ: https://docs.evidence.dev/
- コンポーネント一覧: https://docs.evidence.dev/components/all-components
- GitHub Pages デプロイ: https://docs.evidence.dev/deployment/github-pages
