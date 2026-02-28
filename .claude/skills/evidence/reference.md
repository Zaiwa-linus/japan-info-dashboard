# Evidence リファレンスガイド

> 出典: https://docs.evidence.dev/

## 1. インストールと初期セットアップ

### プロジェクト作成

```bash
npx degit evidence-dev/template my-project
cd my-project
npm install
```

### 開発サーバー起動

```bash
npm run dev
```

オプション:
- `--open [path]`: ブラウザを自動で開く
- `--host [host]`: ホスト名を指定（コンテナ利用時は `0.0.0.0`）
- `--port [port]`: ポートを指定（デフォルト: 3000）

サーバー停止: `Ctrl/Cmd + C`、再起動: `r` キー

### ビルド

```bash
npm run build          # プロダクションビルド
npm run build:strict   # クエリ/コンポーネントエラーがあればビルド失敗
npm run preview        # ビルド結果のプレビュー
```

### データソースの実行

```bash
npm run sources
npm run sources --changed              # 変更されたソースのみ
npm run sources --sources [name]       # 特定のソースのみ
npm run sources --queries [name]       # 特定のクエリのみ
```

大規模データ（100万行以上）の場合:
```bash
NODE_OPTIONS="--max-old-space-size=4096" npm run sources
```

---

## 2. プロジェクト構造

```
evidence_app/
├── pages/              # マークダウンページ（ファイルベースルーティング）
│   ├── index.md        # ホームページ (/)
│   └── sales.md        # /sales ページ
├── sources/            # データソース接続設定
│   └── [source_name]/
│       ├── connection.yaml
│       └── *.sql       # ソースクエリ
├── queries/            # 共有SQLクエリ
├── partials/           # 再利用可能なマークダウンパーツ
├── static/             # 静的ファイル（画像等）
├── evidence.config.yaml
└── package.json
```

### ファイルベースルーティング

| ファイルパス | URL |
|---|---|
| `pages/index.md` | `/` |
| `pages/weekly-sales.md` | `/weekly-sales` |
| `pages/marketing/attribution.md` | `/marketing/attribution` |
| `pages/customers/[customer].md` | `/customers/:customer`（テンプレートページ） |

---

## 3. Evidence-flavored Markdown 構文

### SQLクエリ（インライン）

SQL コードフェンスに名前を付けるとクエリとして実行される（DuckDB SQL方言）:

````markdown
```sql orders_by_month
select
    date_trunc('month', order_datetime) as order_month,
    count(*) as number_of_orders,
    sum(sales) as sales_usd
from needful_things.orders
group by 1
order by 1 desc
```
````

### クエリチェーン

クエリ内で他のクエリ結果を `${}` で参照可能:

````markdown
```sql sales_by_item
select item, sum(sales) as sales
from needful_things.orders
group by 1
```

```sql average_sales
select avg(sales) as average_sales
from ${sales_by_item}
```
````

### 共有SQLファイル

`queries/` ディレクトリに `.sql` ファイルを配置し、frontmatter で参照:

```yaml
---
queries:
  - q4_data: my_file_query.sql
  - q4_sales_reps: some_category/my_query.sql
---
```

### JavaScript式

中括弧 `{}` 内でJavaScript式を実行:

```markdown
2 + 2 = {2 + 2}
全{orders.length}件のデータ
先月の注文数: {orders_by_month[0].number_of_orders}
```

### コンポーネント

```markdown
<LineChart
    data={orders_by_month}
    y=sales_usd
    title="Sales by Month, USD"
/>
```

### ループ ({#each})

```markdown
{#each orders_by_month as month}
- 注文数: <Value data={month} column=number_of_orders/>
{/each}
```

### 条件分岐 ({#if})

```markdown
{#if orders_by_month[0].sales_usd > orders_by_month[1].sales_usd}
売上は前月比で増加しています。
{:else if orders_by_month[0].sales_usd === orders_by_month[1].sales_usd}
売上は前月と同じです。
{:else}
売上は前月比で減少しています。
{/if}
```

### パーシャル（再利用パーツ）

```markdown
{@partial "my-first-partial.md"}
```

`partials/my-first-partial.md` に配置した内容が展開される。

### Frontmatter

```yaml
---
title: ページタイトル
description: ページの説明
og:
  image: /social-image.png
queries:
  - orders_by_month.sql
---
```

### ページ変数

```markdown
現在のパス: {$page.route.id}
```

---

## 4. データソース

### 接続設定の流れ

1. `npm run dev` でアプリを起動
2. `localhost:3000/settings` にアクセス
3. データソースの種類を選択、名前を付け、認証情報を入力
4. `sources/[source_name]/connection.yaml` を必要に応じて編集
5. ソースクエリ（`.sql`）を追加
6. `npm run sources` を実行

### 対応データソース

- **SQL DB**: PostgreSQL, MySQL, SQLite, SQL Server, Snowflake, BigQuery, Redshift, Databricks, Trino
- **軽量DB**: DuckDB, MotherDuck
- **ファイル**: CSV
- **その他**: Google Sheets, JavaScript (API)

### ソースクエリ

`sources/[source_name]/` 内に `.sql` ファイルを配置。結果は `[source_name].[query_name]` として参照可能。

### 環境変数

- データベース認証情報: `EVIDENCE_SOURCE__[source_name]__[variable_name]`
- ソースクエリ用変数: `EVIDENCE_VAR__variable_name=value` → クエリ内で `${variable_name}` として参照
- ページレベル変数: `VITE_` プレフィックス → `import.meta.env.VITE_variable_name`

---

## 5. コンポーネント一覧

### チャート

| コンポーネント | 用途 |
|---|---|
| `<LineChart>` | 時系列の推移 |
| `<AreaChart>` | 面グラフ（時系列・連続値） |
| `<BarChart>` | カテゴリ別比較（縦/横/積上/グループ） |
| `<ScatterPlot>` | 2変数の相関 |
| `<BubbleChart>` | 3変数のバブルチャート |
| `<FunnelChart>` | コンバージョンファネル |
| `<SankeyDiagram>` | カテゴリ間のフロー |
| `<Heatmap>` | ヒートマップ |
| `<CalendarHeatmap>` | カレンダー形式のヒートマップ |
| `<Histogram>` | 分布 |
| `<BoxPlot>` | 箱ひげ図 |
| `<ECharts>` | カスタムECharts |

### データ表示

| コンポーネント | 用途 |
|---|---|
| `<Value>` | インライン値の表示 |
| `<BigValue>` | 大きな数値（比較・スパークライン付き） |
| `<DataTable>` | データテーブル |
| `<Delta>` | 変化量の表示 |

### 入力コンポーネント

| コンポーネント | 用途 |
|---|---|
| `<ButtonGroup>` | 単一選択ボタン |
| `<Dropdown>` | ドロップダウンメニュー |
| `<TextInput>` | テキスト入力 |
| `<DateInput>` | 日付選択 |
| `<DateRange>` | 日付範囲選択 |
| `<Slider>` | スライダー |
| `<Checkbox>` | チェックボックス |
| `<DimensionGrid>` | 多次元フィルタリンググリッド |

### UIコンポーネント

| コンポーネント | 用途 |
|---|---|
| `<Accordion>` | 折りたたみセクション |
| `<Alert>` | アラートメッセージ |
| `<Tabs>` | タブ切り替え |
| `<Modal>` | モーダルダイアログ |
| `<Grid>` | グリッドレイアウト |
| `<Details>` | 展開可能なセクション |
| `<LinkButton>` | リンクボタン |
| `<DownloadData>` | CSVダウンロードボタン |
| `<LastRefreshed>` | データ更新日時 |

### マップ

| コンポーネント | 用途 |
|---|---|
| `<AreaMap>` | コロプレスマップ |
| `<PointMap>` | ポイントマップ |
| `<BubbleMap>` | バブルマップ |
| `<BaseMap>` | 複合マップ（複数レイヤー） |
| `<USMap>` | 米国州別マップ |

---

## 6. フィルタリング

入力コンポーネントとSQLクエリを連携させて動的フィルタリング:

````markdown
```sql categories
select distinct category from orders
```

<Dropdown data={categories} name=selected_category value=category />

```sql filtered_orders
select * from orders
where category = '${inputs.selected_category.value}'
```

<DataTable data={filtered_orders} />
````

ワイルドカード（全件表示）:

```sql
where category like '${inputs.selected_category.value}'
```

クエリパラメータの種類:
- **入力パラメータ**: `${inputs.parameter_name}`
- **URLパラメータ**: `${params.parameter_name}`（テンプレートページ用）

---

## 7. テンプレートページ

ファイル名にブラケット `[]` を使用して動的ページを生成:

```
pages/customers/[customer].md
```

ページ内でパラメータを使用:

````markdown
# {params.customer} の詳細

```sql customer_data
select * from customers
where name = '${params.customer}'
```
````

### リンクの生成方法

DataTableの `link` プロパティ:
```markdown
<DataTable data={customers} link=customer_link />
```

Each ループ:
```markdown
{#each customers as customer}
- [{customer.name}](/customers/{customer.name})
{/each}
```

ネストも可能: `pages/customers/[customer]/[branch].md`

---

## 8. 値フォーマット

### コンポーネント内

```markdown
<Value data={sales} column=revenue fmt="$#,##0.0" />
<Value data={sales} column=revenue fmt=usd2k />
```

### チャート軸

```markdown
<BarChart data={sales} xFmt="mmm yyyy" yFmt=usd0k />
```

### マークダウン式内

```markdown
売上: {fmt(sales[0].revenue, '$#,##0')}
```

### 主なビルトインフォーマット

| カテゴリ | フォーマット例 | 説明 |
|---|---|---|
| 通貨 | `usd`, `usd2`, `usd0k`, `jpy` | 通貨表示 |
| 数値 | `num0`〜`num4`, `num0k`, `num0m` | 数値精度・スケール |
| 割合 | `pct`, `pct0`〜`pct3` | パーセント表示 |
| 日付 | `shortdate`, `longdate`, `mmm yyyy` | 日付表示 |

### SQLカラム名でのフォーマットタグ

カラム名の末尾にフォーマットタグを付与:
```sql
select growth as growth_pct, revenue as revenue_usd
```

---

## 9. テーマとスタイリング

### 外観モード設定（evidence.config.yaml）

```yaml
appearance:
  default: system    # dark, light, system
  switcher: true     # 外観切り替えボタンの表示
```

### カラーパレット

```yaml
theme:
  colorPalettes:
    myCustomPalette:
      light: ["#e11d48", "#be185d"]
      dark: ["#fb7185", "#f9a8d4"]
```

### UIカラートークン

主要トークン: `primary`, `accent`, `base`, `info`, `positive`, `warning`, `negative`

背景バリエーション: `base-100`, `base-200`, `base-300`

### スタイリング

Evidence は **Tailwind CSS** を使用。HTML要素にTailwindクラスを直接適用可能。`markdown` クラスでEvidenceのデフォルトスタイルを継承。

---

## 10. GitHub Pages へのデプロイ

### ベースパス設定

`evidence.config.yaml`:
```yaml
deployment:
  basePath: /my-evidence-app
```

`package.json`:
```json
{
  "scripts": {
    "build": "EVIDENCE_BUILD_DIR=./build/my-evidence-app evidence build"
  }
}
```

### GitHub Actions ワークフロー

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: 'main'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm install
      - name: build
        env:
          BASE_PATH: '/${{ github.event.repository.name }}'
        run: |
          npm run sources
          npm run build
      - uses: actions/upload-pages-artifact@v3
        with:
          path: 'build/${{ github.event.repository.name }}'

  deploy:
    needs: build
    runs-on: ubuntu-latest
    permissions:
      pages: write
      id-token: write
    environment:
      name: github-pages
    steps:
      - uses: actions/deploy-pages@v4
```

### 環境変数の設定

GitHub リポジトリの Settings > Secrets and variables > Actions に以下の形式で追加:

```
EVIDENCE_SOURCE__[source_name]__[option_name]
```

### スケジュール実行（定期更新）

```yaml
on:
  schedule:
    - cron: '0 0 * * *'   # 毎日0時に実行
```

---

## 11. デプロイメント概要

### ビルドの仕組み

Evidence はデフォルトで**静的サイト生成（SSG）**を行う:
- クエリはビルド時に1回だけ実行される
- すべてのページがHTMLとして事前生成される
- ページ読み込みは非常に高速（ミリ秒単位）

### レンダリングモード

1. **静的サイト生成（SSG）**: デフォルト。全ページを事前ビルド
2. **シングルページアプリ（SPA）**: 1000ページ以上ある場合に推奨。事前ビルドをスキップ

### 対応ホスティングサービス

Vercel, Netlify, GitHub Pages, Azure Static Apps, Firebase, Cloudflare Pages, AWS Amplify, GitLab Pages, Hugging Face Spaces
