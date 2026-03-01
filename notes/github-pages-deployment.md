# GitHub Pages デプロイ時の注意点

## 1. ベースパスの設定

GitHub Pages では `https://<user>.github.io/<repo>/` という URL 構造になるため、ベースパスの設定が必要。

### 必要な設定ファイル

**`evidence.config.yaml`**:
```yaml
deployment:
  basePath: /japan-info-dashboard
```

**`package.json`** の build スクリプト:
```json
{
  "scripts": {
    "build": "EVIDENCE_BUILD_DIR=./build/japan-info-dashboard evidence build"
  }
}
```

`basePath` と `EVIDENCE_BUILD_DIR` のディレクトリ名はリポジトリ名と一致させること。

## 2. 静的ファイル（GeoJSON など）のパス指定

### 問題

`static/` 配下のファイルを絶対パス（`/` 始まり）で参照すると、GitHub Pages のベースパスが無視される。

| 指定方法 | ローカル | GitHub Pages | 結果 |
|---|---|---|---|
| `/japan_prefectures.geojson` | `/japan_prefectures.geojson` | `/japan_prefectures.geojson`（ルート直下を参照） | NG |
| `japan_prefectures.geojson` | 現在のページからの相対パス | 現在のページからの相対パス | OK |

### 結論

**`geoJsonUrl` などの静的ファイル参照では先頭の `/` を付けず、相対パスを使う。**

```markdown
<!-- NG: GitHub Pages で 404 になる -->
<AreaMap geoJsonUrl=/japan_prefectures.geojson ... />

<!-- OK: ローカルでも GitHub Pages でも動作する -->
<AreaMap geoJsonUrl=japan_prefectures.geojson ... />
```

注意: この相対パス方式はルートページ（`pages/index.md`）では問題なく動作する。サブディレクトリのページから参照する場合は `../` 等でパスを調整する必要がある。

## 3. GitHub Actions ワークフロー

dbt + Evidence のモノレポ構成では、ワークフローで以下の順序を守る:

1. Python セットアップ → `dbt build`（DuckDB にデータ構築）
2. Node.js セットアップ → `npm run sources` → `npm run build`（静的サイト生成）
3. `upload-pages-artifact` → `deploy-pages`（GitHub Pages へデプロイ）

## 4. GitHub リポジトリ側の設定

Settings > Pages > Source を **GitHub Actions** に変更する（デフォルトは「Deploy from a branch」）。
