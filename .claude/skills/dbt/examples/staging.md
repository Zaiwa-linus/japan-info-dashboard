# Staging 層のサンプルコード

## SQL テンプレート

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

## モデル YAML テンプレート

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

## バリデーションコマンド

```bash
# 全 staging モデルをチェック
uv run python .claude/skills/dbt/validate_column_suffixes.py

# 特定ファイルのみチェック
uv run python .claude/skills/dbt/validate_column_suffixes.py dbt_project/models/staging/stg_xxx.sql
```
