-- [責務] 自然環境の旧気象指標（B4105, B4110, B4112）を都道府県×年で横持ちに変換する
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
    where indicator_code in ('B4105', 'B4110', 'B4112')
        and area_code <> '00000'
)

select
    area_code,
    area_name,
    year_code,
    survey_year,
    max(case when indicator_code = 'B4105' then raw_value end) as cloudy_days,
    max(case when indicator_code = 'B4110' then raw_value end) as max_snow_depth_cm,
    max(case when indicator_code = 'B4112' then raw_value end) as min_relative_humidity_pct
from source
group by area_code, area_name, year_code, survey_year
