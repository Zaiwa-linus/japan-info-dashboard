-- [責務] 自然環境の林野面積指標（B1105-B1107）を都道府県×年で横持ちに変換する
-- [ユニークキー] area_code, survey_year
-- [入力] stg_natural_environment
with source as (
    select
        area_code,
        area_name,
        year_code,
        survey_year,
        indicator_code,
        raw_value
    from {{ ref('stg_natural_environment') }}
    where indicator_code in ('B1105', 'B1106', 'B1107')
        and area_code <> '00000'
)

select
    area_code,
    area_name,
    year_code,
    survey_year,
    max(case when indicator_code = 'B1105' then raw_value end) as forest_and_field_area_ha,
    max(case when indicator_code = 'B1106' then raw_value end) as forest_area_ha,
    max(case when indicator_code = 'B1107' then raw_value end) as grassland_area_ha
from source
group by area_code, area_name, year_code, survey_year
