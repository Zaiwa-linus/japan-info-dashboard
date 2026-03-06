-- [責務] 自然環境の自然公園指標（B21xx）を都道府県×年で横持ちに変換する
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
    where indicator_code like 'B21%'
        and area_code <> '00000'
)

select
    area_code,
    area_name,
    year_code,
    survey_year,
    max(case when indicator_code = 'B2101' then raw_value end) as natural_park_area_ha,
    max(case when indicator_code = 'B2102' then raw_value end) as prefectural_park_count,
    max(case when indicator_code = 'B2103' then raw_value end) as prefectural_park_area_ha,
    max(case when indicator_code = 'B2104' then raw_value end) as national_park_area_ha,
    max(case when indicator_code = 'B2105' then raw_value end) as quasi_national_park_area_ha
from source
group by area_code, area_name, year_code, survey_year
