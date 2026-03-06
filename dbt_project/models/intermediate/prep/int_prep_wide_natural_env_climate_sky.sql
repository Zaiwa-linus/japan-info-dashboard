-- [責務] 自然環境の天候日数指標（B4104, B4107）を都道府県×年で横持ちに変換する
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
    where indicator_code in ('B4104', 'B4107')
        and area_code <> '00000'
)

select
    area_code,
    area_name,
    year_code,
    survey_year,
    max(case when indicator_code = 'B4104' then raw_value end) as clear_sky_days,
    max(case when indicator_code = 'B4107' then raw_value end) as snow_days
from source
group by area_code, area_name, year_code, survey_year
