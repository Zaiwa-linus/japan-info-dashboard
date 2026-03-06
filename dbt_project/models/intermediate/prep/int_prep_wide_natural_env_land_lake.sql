-- [責務] 自然環境の主要湖沼面積指標（B1104）を都道府県×年で抽出する
-- [ユニークキー] area_code, survey_year
-- [入力] stg_natural_environment
select
    area_code,
    area_name,
    year_code,
    survey_year,
    raw_value as major_lake_area_ha
from {{ ref('stg_natural_environment') }}
where indicator_code = 'B1104'
    and area_code <> '00000'
    and raw_value is not null
