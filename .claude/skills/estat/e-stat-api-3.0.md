# e-Stat API 3.0 仕様書

> 出典: https://www.e-stat.go.jp/api/api-info/e-stat-manual3-0
> 本仕様書はJSON形式利用を前提としてまとめたものです。

---

## 1. 概要

e-Stat API 3.0は、政府統計の総合窓口(e-Stat)が提供するデータ取得用REST APIである。

### 1.1 ベースURL

```
https://api.e-stat.go.jp/rest/3.0/app/json/{機能名}
```

JSON形式の場合、パスに `/json/` を挿入する。

### 1.2 認証

全APIリクエストに `appId`（アプリケーションID）が必須。ユーザー登録により取得する。

### 1.3 共通パラメータ

| パラメータ | 必須 | 説明 | 値 |
|-----------|------|------|-----|
| appId | Yes | アプリケーションID | 登録時に取得したID |
| lang | No | 言語 | `J`（日本語、デフォルト）, `E`（英語） |

### 1.4 JSON出力時の注意

- 全角文字はUnicodeエスケープされる（例: `国勢調査` → `\u56FD\u52E2\u8ABF\u67FB`）
- `<`, `>`, `&`, `=`, `'` はUnicodeエスケープされる
- ダブルクォート・バックスラッシュはバックスラッシュエスケープされる

### 1.5 共通レスポンス構造

全APIレスポンスは以下の3セクションで構成される:

```json
{
  "ROOT_TAG": {
    "RESULT": {
      "STATUS": 0,
      "ERROR_MSG": "正常に処理されました。",
      "DATE": "2024-01-01T00:00:00.000+09:00"
    },
    "PARAMETER": { },
    "DATA_SECTION": { }
  }
}
```

### 1.6 ステータスコード

| コード | 意味 |
|-------|------|
| 0 | 正常終了 |
| 1 | 正常終了（該当データなし） |
| 2 | 正常終了（上限超過のためデータ一部返却） |
| 100 | 認証エラー（appIdが無効） |
| 102 | パラメータ不正 |
| 200〜299 | データベースアクセスエラー |
| 300以上 | データ固有のエラー |

---

## 2. API一覧

| # | 機能名 | 説明 | メソッド |
|---|--------|------|----------|
| 2.1 | getStatsList | 統計表情報取得 | GET |
| 2.2 | getMetaInfo | メタ情報取得 | GET |
| 2.3 | getStatsData | 統計データ取得 | GET |
| 2.4 | postDataset | データセット登録 | POST |
| 2.5 | refDataset | データセット参照 | GET |
| 2.6 | getDataCatalog | データカタログ情報取得 | GET |
| 2.7 | getStatsDatas | 統計データ一括取得 | POST |

---

## 2.1 統計表情報取得（getStatsList）

統計表の情報を検索・取得する。

### エンドポイント

```
GET https://api.e-stat.go.jp/rest/3.0/app/json/getStatsList
```

### リクエストパラメータ

| パラメータ | 必須 | 型 | 説明 | 値 |
|-----------|------|-----|------|-----|
| appId | Yes | String | アプリケーションID | |
| lang | No | String | 言語 | `J`, `E` |
| surveyYears | No | String | 調査年月 | `yyyy`, `yyyymm`, `yyyymm-yyyymm` |
| openYears | No | String | 公開年月 | `yyyy`, `yyyymm`, `yyyymm-yyyymm` |
| statsField | No | String | 統計分野 | 2桁（大分類）, 4桁（小分類） |
| statsCode | No | String | 政府統計コード | 5桁（作成機関）, 8桁（統計コード） |
| searchWord | No | String | 検索キーワード | AND/OR/NOT演算子使用可 |
| searchKind | No | Integer | データ種別 | `1`（統計情報、デフォルト）, `2`（小地域・地域メッシュ） |
| collectArea | No | Integer | 集計地域区分 | `1`（全国）, `2`（都道府県）, `3`（市区町村） |
| explanationGetFlg | No | String | 解説情報取得フラグ | `Y`（取得、デフォルト）, `N`（取得しない） |
| statsNameList | No | String | 調査名一覧取得 | `Y`で調査名一覧を返却 |
| startPosition | No | Integer | 開始行番号 | 1以上（デフォルト: 1） |
| limit | No | Integer | 取得件数 | デフォルト: 100,000 |
| updatedDate | No | String | 更新日付 | `yyyy`, `yyyymm`, `yyyymmdd`, `yyyymmdd-yyyymmdd` |

### レスポンス構造

```json
{
  "GET_STATS_LIST": {
    "RESULT": {
      "STATUS": 0,
      "ERROR_MSG": "string",
      "DATE": "datetime"
    },
    "PARAMETER": { },
    "DATALIST_INF": {
      "NUMBER": 100,
      "RESULT_INF": {
        "FROM_NUMBER": 1,
        "TO_NUMBER": 100,
        "NEXT_KEY": 101
      },
      "TABLE_INF": [
        {
          "@id": "統計表ID",
          "STAT_NAME": { "@code": "統計コード", "$": "統計名" },
          "GOV_ORG": { "@code": "機関コード", "$": "機関名" },
          "STATISTICS_NAME": "統計調査名",
          "TITLE": { "@no": "表番号", "$": "統計表タイトル" },
          "CYCLE": "周期",
          "SURVEY_DATE": "調査日",
          "OPEN_DATE": "公開日",
          "SMALL_AREA": 0,
          "COLLECT_AREA": "集計地域区分",
          "MAIN_CATEGORY": { "@code": "コード", "$": "大分類名" },
          "SUB_CATEGORY": { "@code": "コード", "$": "小分類名" },
          "OVERALL_TOTAL_NUMBER": 1000,
          "UPDATED_DATE": "更新日",
          "STATISTICS_NAME_SPEC": {
            "TABULATION_CATEGORY": "集計名",
            "TABULATION_SUB_CATEGORY1": "サブカテゴリ1"
          },
          "DESCRIPTION": "",
          "TITLE_SPEC": {
            "TABLE_CATEGORY": "表分類",
            "TABLE_NAME": "表名"
          }
        }
      ]
    }
  }
}
```

---

## 2.2 メタ情報取得（getMetaInfo）

統計表のメタ情報（分類情報等）を取得する。

### エンドポイント

```
GET https://api.e-stat.go.jp/rest/3.0/app/json/getMetaInfo
```

### リクエストパラメータ

| パラメータ | 必須 | 型 | 説明 | 値 |
|-----------|------|-----|------|-----|
| appId | Yes | String | アプリケーションID | |
| lang | No | String | 言語 | `J`, `E` |
| statsDataId | Yes | String | 統計表ID | getStatsListの結果から取得 |
| explanationGetFlg | No | String | 解説情報取得フラグ | `Y`（取得）, `N`（取得しない） |

### レスポンス構造

```json
{
  "GET_META_INFO": {
    "RESULT": {
      "STATUS": 0,
      "ERROR_MSG": "string",
      "DATE": "datetime"
    },
    "PARAMETER": {
      "LANG": "J",
      "STATS_DATA_ID": "string",
      "EXPLANATION_GET_FLG": "Y"
    },
    "METADATA_INF": {
      "TABLE_INF": {
        "@id": "統計表ID",
        "STAT_NAME": { "@code": "コード", "$": "統計名" },
        "GOV_ORG": { "@code": "コード", "$": "機関名" },
        "STATISTICS_NAME": "統計調査名",
        "TITLE": "統計表タイトル",
        "CYCLE": "周期",
        "SURVEY_DATE": "調査日",
        "OPEN_DATE": "公開日",
        "OVERALL_TOTAL_NUMBER": 1000,
        "UPDATED_DATE": "更新日",
        "DESCRIPTION": ""
      },
      "CLASS_INF": {
        "CLASS_OBJ": [
          {
            "@id": "分類ID（tab, time, area, cat01〜cat15等）",
            "@name": "分類名",
            "CLASS": [
              {
                "@code": "分類コード",
                "@name": "分類名",
                "@level": "階層レベル",
                "@unit": "単位（該当する場合）",
                "@parentCode": "親コード（階層構造の場合）"
              }
            ]
          }
        ]
      }
    }
  }
}
```

---

## 2.3 統計データ取得（getStatsData）

統計データ本体を取得する。最も利用頻度の高いAPI。

### エンドポイント

```
GET https://api.e-stat.go.jp/rest/3.0/app/json/getStatsData
```

### リクエストパラメータ

#### データ指定（いずれか一方が必須）

| パラメータ | 必須 | 型 | 説明 |
|-----------|------|-----|------|
| statsDataId | ※ | String | 統計表ID（getStatsListから取得） |
| dataSetId | ※ | String | データセットID（postDatasetで登録したもの） |

※ いずれか一方を指定（両方指定は不可）

#### 絞り込み条件

各分類（tab, time, area, cat01〜cat15）に対して以下のパラメータが使用可能:

| パターン | パラメータ例 | 説明 |
|---------|------------|------|
| 階層レベル | lvTab, lvTime, lvArea, lvCat01〜lvCat15 | 絞り込む階層レベル。`X`, `X-X`, `-X`, `X-` 形式 |
| 単一コード | cdTab, cdTime, cdArea, cdCat01〜cdCat15 | カンマ区切りで最大100件指定 |
| コード範囲（開始） | cdTabFrom, cdTimeFrom, cdAreaFrom, cdCat01From〜cdCat15From | 範囲の開始コード |
| コード範囲（終了） | cdTabTo, cdTimeTo, cdAreaTo, cdCat01To〜cdCat15To | 範囲の終了コード |

- コード範囲には特殊キーワード `min`（最小値）、`max`（最大値）が使用可能

#### データ取得オプション

| パラメータ | 必須 | 型 | 説明 | 値 |
|-----------|------|-----|------|-----|
| startPosition | No | Integer | 取得開始位置 | デフォルト: 1 |
| limit | No | Integer | 最大取得件数 | デフォルト: 100,000 |
| metaGetFlg | No | String | メタ情報取得フラグ | `Y`（取得、デフォルト）, `N` |
| cntGetFlg | No | String | 件数のみ取得フラグ | `Y`（件数のみ）, `N`（デフォルト） |
| explanationGetFlg | No | String | 解説情報取得フラグ | `Y`（デフォルト）, `N` |
| annotationGetFlg | No | String | 注釈情報取得フラグ | `Y`（デフォルト）, `N` |
| replaceSpChar | No | Integer | 特殊文字の置換 | `0`（置換しない）, `1`〜`3`（置換パターン） |

### レスポンス構造

```json
{
  "GET_STATS_DATA": {
    "RESULT": {
      "STATUS": 0,
      "ERROR_MSG": "string",
      "DATE": "datetime"
    },
    "PARAMETER": { },
    "STATISTICAL_DATA": {
      "RESULT_INF": {
        "TOTAL_NUMBER": 1000,
        "FROM_NUMBER": 1,
        "TO_NUMBER": 100,
        "NEXT_KEY": 101
      },
      "TABLE_INF": {
        "@id": "統計表ID",
        "STAT_NAME": { "@code": "コード", "$": "統計名" },
        "GOV_ORG": { "@code": "コード", "$": "機関名" },
        "STATISTICS_NAME": "統計調査名",
        "TITLE": "統計表タイトル",
        "CYCLE": "周期",
        "SURVEY_DATE": "調査日",
        "OPEN_DATE": "公開日",
        "OVERALL_TOTAL_NUMBER": 1000,
        "UPDATED_DATE": "更新日"
      },
      "CLASS_INF": {
        "CLASS_OBJ": [
          {
            "@id": "分類ID",
            "@name": "分類名",
            "CLASS": [
              {
                "@code": "コード",
                "@name": "名称",
                "@level": "レベル",
                "@unit": "単位"
              }
            ]
          }
        ]
      },
      "DATA_INF": {
        "NOTE": [
          { "@char": "特殊文字", "$": "説明" }
        ],
        "VALUE": [
          {
            "@tab": "表章事項コード",
            "@cat01": "分類01コード",
            "@cat02": "分類02コード",
            "@area": "地域コード",
            "@time": "時間軸コード",
            "@unit": "単位",
            "$": "データ値"
          }
        ]
      }
    }
  }
}
```

#### VALUE要素の説明

- 各VALUEオブジェクトには、分類に対応する属性（`@tab`, `@cat01`〜`@cat15`, `@area`, `@time` 等）が付与される
- `$` がデータ値本体
- 特殊文字（`-`, `x`, `…` 等）はNOTEで定義される意味を持つ

---

## 2.4 データセット登録（postDataset）

絞り込み条件を保存し、データセットとして登録する。

### エンドポイント

```
POST https://api.e-stat.go.jp/rest/3.0/app/json/postDataset
```

### リクエストパラメータ

| パラメータ | 必須 | 型 | 説明 | 値 |
|-----------|------|-----|------|-----|
| appId | Yes | String | アプリケーションID | |
| lang | No | String | 言語 | `J`, `E` |
| dataSetId | ※ | String | データセットID | 最大30文字。英数字, `-`, `_`, `.`, `@`。省略時は自動採番 |
| statsDataId | ※ | String | 統計表ID | getStatsListの結果から |
| openSpecified | No | String | 公開設定 | `0`（非公開、デフォルト）, `1`（公開） |
| processMode | No | String | 処理モード | `E`（登録/更新、デフォルト）, `D`（削除） |
| dataSetName | No | String | データセット名 | 最大256全角文字 |

※ 登録時はstatsDataIdが必要。絞り込み条件も最低1つ指定が必要。

絞り込み条件パラメータはgetStatsDataと同一（lvTab, cdTab, lvTime, cdTime, lvArea, cdArea, lvCat01〜lvCat15等）。

### レスポンス構造

```json
{
  "POST_DATASET": {
    "RESULT": {
      "STATUS": 0,
      "ERROR_MSG": "string",
      "DATE": "datetime"
    },
    "PARAMETER": { },
    "DATASET_ID": "登録されたデータセットID"
  }
}
```

---

## 2.5 データセット参照（refDataset）

登録済みデータセットの一覧・詳細を参照する。

### エンドポイント

```
GET https://api.e-stat.go.jp/rest/3.0/app/json/refDataset
```

### リクエストパラメータ

| パラメータ | 必須 | 型 | 説明 | 値 |
|-----------|------|-----|------|-----|
| appId | Yes | String | アプリケーションID | |
| lang | No | String | 言語 | `J`, `E` |
| dataSetId | No | String | データセットID | 特定のデータセットを指定。省略時は一覧取得 |
| collectArea | No | String | 集計地域区分 | `1`（全国）, `2`（都道府県）, `3`（市区町村） |
| explanationGetFlg | No | String | 解説情報取得フラグ | `Y`（デフォルト）, `N` |

### レスポンス構造

```json
{
  "GET_DATASET_LIST": {
    "RESULT": {
      "STATUS": 0,
      "ERROR_MSG": "string",
      "DATE": "datetime"
    },
    "PARAMETER": { },
    "DATASET_LIST_INF": {
      "NUMBER": 10,
      "DATASET_INF": [
        {
          "@id": "データセットID",
          "DATASET_NAME": "データセット名",
          "PUBLIC_STATE": "公開状態",
          "RESULT_INF": {
            "TOTAL_NUMBER": 1000
          },
          "TABLE_INF": {
            "@id": "統計表ID",
            "STAT_NAME": { "@code": "コード", "$": "統計名" },
            "GOV_ORG": { "@code": "コード", "$": "機関名" },
            "TITLE": "タイトル"
          }
        }
      ]
    }
  }
}
```

---

## 2.6 データカタログ情報取得（getDataCatalog）

e-Statで提供されるデータカタログ情報を取得する。

### エンドポイント

```
GET https://api.e-stat.go.jp/rest/3.0/app/json/getDataCatalog
```

### リクエストパラメータ

| パラメータ | 必須 | 型 | 説明 | 値 |
|-----------|------|-----|------|-----|
| appId | Yes | String | アプリケーションID | |
| lang | No | String | 言語 | `J`, `E` |
| surveyYears | No | String | 調査年月 | `yyyy`, `yyyymm`, `yyyymm-yyyymm` |
| openYears | No | String | 公開年月 | `yyyy`, `yyyymm`, `yyyymm-yyyymm` |
| statsField | No | String | 統計分野 | 2桁（大分類）, 4桁（小分類） |
| statsCode | No | String | 政府統計コード | 5桁, 8桁 |
| searchWord | No | String | 検索キーワード | AND/OR/NOT演算子使用可 |
| collectArea | No | String | 集計地域区分 | `1`, `2`, `3` |
| explanationGetFlg | No | String | 解説情報取得フラグ | `Y`（デフォルト）, `N` |
| dataType | No | String | データ形式 | `XLS`, `CSV`, `PDF`, `XML`, `XLS_REP`, `DB`（カンマ区切り） |
| catalogId | No | String | カタログID | |
| resourceId | No | String | カタログリソースID | |
| startPosition | No | Integer | 開始位置 | デフォルト: 1 |
| limit | No | Integer | 取得件数 | デフォルト: 100 |
| updatedDate | No | String | 更新日付 | `yyyy`, `yyyymm`, `yyyymmdd`, `yyyymmdd-yyyymmdd` |

### レスポンス構造

```json
{
  "GET_DATA_CATALOG": {
    "RESULT": {
      "STATUS": 0,
      "ERROR_MSG": "string",
      "DATE": "datetime"
    },
    "PARAMETER": { },
    "DATA_CATALOG_LIST_INF": {
      "NUMBER": 100,
      "RESULT_INF": {
        "FROM_NUMBER": 1,
        "TO_NUMBER": 100,
        "NEXT_KEY": 101
      },
      "DATA_CATALOG_INF": [
        {
          "DATASET": {
            "STAT_NAME": { "@code": "コード", "$": "統計名" },
            "ORGANIZATION": { "@code": "コード", "$": "機関名" },
            "TITLE": {
              "NAME": "タイトル名",
              "CYCLE": "周期"
            },
            "RESOURCES": {
              "RESOURCE": [
                {
                  "URL": "ダウンロードURL",
                  "FORMAT": "XLS|CSV|PDF|XML|XLS_REP|DB"
                }
              ]
            }
          }
        }
      ]
    }
  }
}
```

---

## 2.7 統計データ一括取得（getStatsDatas）

複数の統計データを一括で取得する。

### エンドポイント

```
POST https://api.e-stat.go.jp/rest/3.0/app/json/getStatsDatas
```

**Content-Type**: `application/x-www-form-urlencoded`

### リクエストパラメータ

#### グローバルパラメータ

| パラメータ | 必須 | 型 | 説明 | 値 |
|-----------|------|-----|------|-----|
| appId | Yes | String | アプリケーションID | |
| lang | No | String | 言語 | `J`, `E` |
| metaGetFlg | No | String | メタ情報取得フラグ | `Y`（デフォルト）, `N` |
| explanationGetFlg | No | String | 解説情報取得フラグ | `Y`（デフォルト）, `N` |
| annotationGetFlg | No | String | 注釈情報取得フラグ | `Y`（デフォルト）, `N` |
| replaceSpChar | No | Integer | 特殊文字置換 | `0`〜`3` |

#### 一括取得仕様

| パラメータ | 必須 | 型 | 説明 |
|-----------|------|-----|------|
| statsDatasSpec | Yes | JSON配列 | 各リクエスト仕様のJSON配列 |

#### statsDatasSpec内の各リクエストパラメータ

getStatsDataと同一のパラメータが使用可能（dataSetId/statsDataId、絞り込み条件、startPosition、limit等）。

**制約**: 全リクエストの合計セル数上限は100,000件。

### レスポンス構造

```json
{
  "GET_STATS_DATAS": {
    "RESULT": {
      "STATUS": 0,
      "ERROR_MSG": "string",
      "DATE": "datetime"
    },
    "PARAMETER_LIST": {
      "LANG": "J",
      "PARAMETER": [
        { "@requestNo": "1" }
      ]
    },
    "STATISTICAL_DATA_LIST": {
      "RESULT_INF": {
        "TOTAL_NUMBER": 5000
      },
      "TABLE_INF_LIST": {
        "TABLE_INF": []
      },
      "CLASS_INF_LIST": {
        "CLASS_INF": [
          { "@requestNo": "1" }
        ]
      },
      "DATA_INF_LIST": {
        "DATA_INF": [
          { "@requestNo": "1" }
        ]
      }
    }
  }
}
```

各レスポンスセクションには `@requestNo` 属性が付与され、リクエストとの対応関係が識別可能。

---

## 3. ページネーション

データ件数が多い場合、`startPosition` と `limit` を使用してページネーションを行う。

- レスポンスの `NEXT_KEY` に次回取得開始位置が返却される
- `NEXT_KEY` が存在しない場合、全データ取得完了
- デフォルト上限は100,000件

```
# 例: 2ページ目を取得
?appId=xxx&statsDataId=yyy&startPosition=100001&limit=100000
```

---

## 4. エラーメッセージ

エラーメッセージにはプレースホルダが含まれる場合がある:
- `{0}`: パラメータ名
- `{1}`: 制約値
- `{2}`: 詳細説明

一括取得（getStatsDatas）では、エラーにリクエスト番号が付与され、どのリクエストでエラーが発生したか特定可能。
