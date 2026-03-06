-- 自然環境 - 植生自然度（B31xx）
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
    where indicator_code like 'B31%'
)

select
    area_code,
    area_name,
    year_code,
    survey_year,
    max(case when indicator_code = 'B3101' then raw_value end) as vegetation_naturalness_1_pct,
    max(case when indicator_code = 'B3102' then raw_value end) as vegetation_naturalness_2_pct,
    max(case when indicator_code = 'B3103' then raw_value end) as vegetation_naturalness_3_pct,
    max(case when indicator_code = 'B3104' then raw_value end) as vegetation_naturalness_4_pct,
    max(case when indicator_code = 'B3105' then raw_value end) as vegetation_naturalness_5_pct,
    max(case when indicator_code = 'B3106' then raw_value end) as vegetation_naturalness_6_pct,
    max(case when indicator_code = 'B3107' then raw_value end) as vegetation_naturalness_7_pct,
    max(case when indicator_code = 'B3108' then raw_value end) as vegetation_naturalness_8_pct,
    max(case when indicator_code = 'B3109' then raw_value end) as vegetation_naturalness_9_pct,
    max(case when indicator_code = 'B3110' then raw_value end) as vegetation_naturalness_10_pct
from source
group by area_code, area_name, year_code, survey_year
