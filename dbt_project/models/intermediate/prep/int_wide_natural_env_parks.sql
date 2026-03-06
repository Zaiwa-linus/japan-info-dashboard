-- 自然環境 - 自然公園（B21xx）
-- ユニークキー: area_code, survey_year
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
