# Evidence の DuckDB データソース パス解決の注意点

## 問題

Evidence で DuckDB のファイルパスを `connection.yaml` に相対パスで指定する際、パスの基準ディレクトリが直感的ではない。

## 結論

**`sources/[source_name]/` ディレクトリが基準になる。**

`evidence_app/` やプロジェクトルートではない点に注意。

## 例

ディレクトリ構成:

```
project-root/
├── dbt_project/
│   └── target/
│       └── dev.duckdb       ← これを参照したい
└── evidence_app/
    └── sources/
        └── japan_stats/
            └── connection.yaml  ← ここから相対パスを指定
```

`connection.yaml` の設定:

```yaml
name: japan_stats
type: duckdb
options:
  filename: ../../../dbt_project/target/dev.duckdb
```

パスの解決:
- `sources/japan_stats/` → `../` → `sources/` → `../` → `evidence_app/` → `../` → `project-root/`

## よくある間違い

| 指定したパス | 解決先 | 結果 |
|---|---|---|
| `../../dbt_project/target/dev.duckdb` | `evidence_app/dbt_project/...` | NG |
| `../dbt_project/target/dev.duckdb` | `evidence_app/sources/dbt_project/...` | NG |
| `../../../dbt_project/target/dev.duckdb` | `project-root/dbt_project/...` | OK |
