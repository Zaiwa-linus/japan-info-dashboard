---
name: estat
description: e-Stat API を使った統計データの検索・メタ情報取得・CSVダウンロードの手順ガイド。新しい統計データをプロジェクトに追加する際に使用する。
---

# e-Stat API データ取得ガイド

e-Stat（政府統計の総合窓口）から統計データを検索・取得し、プロジェクトの `data/` ディレクトリにCSVとして保存するためのツール群。


## 前提条件

- 環境変数 `ESTAT_API_APPID` または `.env` ファイルに API キーを設定済みであること
- API キーは https://www.e-stat.go.jp/api/ でユーザー登録して取得する

## データ取得の3ステップ

### Step 1: 統計表を検索する（search_stats.py）

```bash
# キーワードで検索
uv run python Estat/search_stats.py "人口"

# 統計分野コードで絞り込み（例: 11=運輸・観光）
uv run python Estat/search_stats.py "観光" --field 11

# 調査年で絞り込み
uv run python Estat/search_stats.py "労働力" --years 2023

# 取得件数を変更（デフォルト50件）
uv run python Estat/search_stats.py "GDP" --limit 20

# 統計分野コード一覧を表示
uv run python Estat/search_stats.py --list-fields

# JSON形式で出力
uv run python Estat/search_stats.py "人口" --json
```

出力から目的の **統計表ID**（例: `0003317252`）を控える。

#### 統計分野コード一覧

| コード | 分野名 |
|--------|--------|
| 01 | 人口・世帯 |
| 02 | 自然環境 |
| 03 | 経済基盤構造 |
| 04 | 政府・財政・金融 |
| 05 | 農林水産業 |
| 06 | 鉱工業 |
| 07 | 商業・サービス業 |
| 08 | 企業活動 |
| 09 | 住宅・土地・建設 |
| 10 | エネルギー・水 |
| 11 | 運輸・観光 |
| 12 | 情報通信・科学技術 |
| 13 | 教育・文化・スポーツ・生活 |
| 14 | 行財政 |
| 15 | 司法・安全・環境 |
| 16 | 社会保障・衛生 |
| 17 | 国際 |
| 18 | その他 |

### Step 2: メタ情報を確認する（get_meta.py）

統計表の分類軸（どんなカラムがあるか、コード体系）を確認する。

```bash
# メタ情報を表示
uv run python Estat/get_meta.py 0003317252

# JSON形式で出力
uv run python Estat/get_meta.py 0003317252 --json
```

出力される情報:
- 統計名、タイトル、提供機関、周期、調査日
- 分類情報（tab, cat01〜cat15, area, time 等）ごとのコードと名称一覧

### Step 3: データをCSVとしてダウンロードする（download_data.py）

```bash
# 必ず -o で英名の概要をファイル名に指定して保存する
# 例: 都道府県別人口データの場合
uv run python Estat/download_data.py 0003317252 -o data/0003317252/population_by_prefecture.csv
```

- **必ず `-o` オプションで英名の概要をファイル名に指定すること**（例: `population_by_prefecture.csv`, `tourist_spending.csv`）
- デフォルトでは `data/{統計表ID}/` ディレクトリを作成し、CSVと `description.md` を保存
- `description.md` にはAPIから取得した統計名・タイトル・提供機関・周期等の概要を記載
- ページネーション対応（10万件超のデータも自動で全件取得）
- メタ情報から分類コード→名称のマッピングを自動解決
- 出力CSVのカラム: `{分類名}_code`, `{分類名}`, ..., `unit`, `value`

## ダウンロード後の作業フロー

1. CSVを `data/{統計表ID}/` に配置（download_data.py のデフォルト出力先）
2. dbt の `models/staging/sources.yml` にソース定義を追加
3. `models/staging/stg_*.sql` でクレンジング（型変換、カラム名統一）
4. 必要に応じて `models/intermediate/` で中間処理
5. `models/marts/` で集計し、Evidence から参照

## e-Stat API 仕様の要点

- ベースURL: `https://api.e-stat.go.jp/rest/3.0/app/json/{機能名}`
- 全リクエストに `appId` が必須
- 主要API: `getStatsList`（検索）、`getMetaInfo`（メタ情報）、`getStatsData`（データ取得）
- ステータスコード: 0=正常、1=該当なし、2=上限超過（部分返却）、100=認証エラー
- ページネーション: レスポンスの `NEXT_KEY` で次ページ位置を取得
- 詳細仕様は `Spec/e-stat-api-3.0.md` を参照
