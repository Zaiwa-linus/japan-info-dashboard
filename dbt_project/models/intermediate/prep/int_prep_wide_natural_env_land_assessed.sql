-- [責務] 自然環境の評価総地積・基本分類（B1201, B120101-B120103）を都道府県×年で横持ちに変換する
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
    where indicator_code in ('B1201', 'B120101', 'B120102', 'B120103')
        and area_code <> '00000'
)

select
    area_code,
    area_name,
    year_code,
    survey_year,
    max(case when indicator_code = 'B1201' then raw_value end) as assessed_land_total_m2,
    max(case when indicator_code = 'B120101' then raw_value end) as assessed_land_paddy_m2,
    max(case when indicator_code = 'B120102' then raw_value end) as assessed_land_field_m2,
    max(case when indicator_code = 'B120103' then raw_value end) as assessed_land_residential_m2
from source
group by area_code, area_name, year_code, survey_year
