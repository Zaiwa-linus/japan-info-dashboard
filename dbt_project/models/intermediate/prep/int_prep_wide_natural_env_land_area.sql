-- [責務] 自然環境の基本面積指標（B1101-B1103, B1108）を都道府県×年で横持ちに変換する
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
    where indicator_code in ('B1101', 'B1102', 'B1103', 'B1108')
        and area_code <> '00000'
)

select
    area_code,
    area_name,
    year_code,
    survey_year,
    max(case when indicator_code = 'B1101' then raw_value end) as total_area_excl_northern_ha,
    max(case when indicator_code = 'B1102' then raw_value end) as total_area_incl_northern_ha,
    max(case when indicator_code = 'B1103' then raw_value end) as habitable_area_ha,
    max(case when indicator_code = 'B1108' then raw_value end) as nature_conservation_area_ha
from source
group by area_code, area_name, year_code, survey_year
