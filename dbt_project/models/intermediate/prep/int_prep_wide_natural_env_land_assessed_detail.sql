-- [責務] 自然環境の評価総地積・詳細分類（B120104-B120107）を都道府県×年で横持ちに変換する
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
    where indicator_code in ('B120104', 'B120105', 'B120106', 'B120107')
        and area_code <> '00000'
)

select
    area_code,
    area_name,
    year_code,
    survey_year,
    max(case when indicator_code = 'B120104' then raw_value end) as assessed_land_mountain_m2,
    max(case when indicator_code = 'B120105' then raw_value end) as assessed_land_pasture_m2,
    max(case when indicator_code = 'B120106' then raw_value end) as assessed_land_wasteland_m2,
    max(case when indicator_code = 'B120107' then raw_value end) as assessed_land_other_m2
from source
group by area_code, area_name, year_code, survey_year
