-- 自然環境 - 気象（B41xx）
-- ユニークキー: area_code, year
with source as (
    select
        area_code,
        area_name,
        year_code,
        year,
        indicator_code,
        raw_value
    from {{ ref('stg_natural_environment') }}
    where indicator_code like 'B41%'
)

select
    area_code,
    area_name,
    year_code,
    year,
    max(case when indicator_code = 'B4101' then raw_value end) as avg_temperature_celsius,
    max(case when indicator_code = 'B4102' then raw_value end) as max_temperature_celsius,
    max(case when indicator_code = 'B4103' then raw_value end) as min_temperature_celsius,
    max(case when indicator_code = 'B4104' then raw_value end) as clear_sky_days,
    max(case when indicator_code = 'B4105' then raw_value end) as cloudy_days,
    max(case when indicator_code = 'B4106' then raw_value end) as rainy_days,
    max(case when indicator_code = 'B4107' then raw_value end) as snow_days,
    max(case when indicator_code = 'B4108' then raw_value end) as sunshine_hours,
    max(case when indicator_code = 'B4109' then raw_value end) as precipitation_mm,
    max(case when indicator_code = 'B4110' then raw_value end) as max_snow_depth_cm,
    max(case when indicator_code = 'B4111' then raw_value end) as avg_relative_humidity_pct,
    max(case when indicator_code = 'B4112' then raw_value end) as min_relative_humidity_pct
from source
group by area_code, area_name, year_code, year
