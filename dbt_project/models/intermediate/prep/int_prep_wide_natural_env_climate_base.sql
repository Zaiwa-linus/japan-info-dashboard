-- [責務] 自然環境の基本気象指標（B4101-B4103, B4106, B4108, B4109, B4111）を都道府県×年で横持ちに変換する
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
    where indicator_code in ('B4101', 'B4102', 'B4103', 'B4106', 'B4108', 'B4109', 'B4111')
        and area_code <> '00000'
)

select
    area_code,
    area_name,
    year_code,
    survey_year,
    max(case when indicator_code = 'B4101' then raw_value end) as avg_temperature_celsius,
    max(case when indicator_code = 'B4102' then raw_value end) as max_temperature_celsius,
    max(case when indicator_code = 'B4103' then raw_value end) as min_temperature_celsius,
    max(case when indicator_code = 'B4106' then raw_value end) as rainy_days,
    max(case when indicator_code = 'B4108' then raw_value end) as sunshine_hours,
    max(case when indicator_code = 'B4109' then raw_value end) as precipitation_mm,
    max(case when indicator_code = 'B4111' then raw_value end) as avg_relative_humidity_pct
from source
group by area_code, area_name, year_code, survey_year
