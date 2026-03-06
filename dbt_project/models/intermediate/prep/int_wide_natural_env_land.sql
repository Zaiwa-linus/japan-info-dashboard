-- 自然環境 - 土地面積・地積（B11xx, B12xx, B13xx）
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
    where indicator_code like 'B11%'
        or indicator_code like 'B12%'
        or indicator_code = 'B1303'
)

select
    area_code,
    area_name,
    year_code,
    survey_year,
    max(case when indicator_code = 'B1101' then raw_value end) as total_area_excl_northern_ha,
    max(case when indicator_code = 'B1102' then raw_value end) as total_area_incl_northern_ha,
    max(case when indicator_code = 'B1103' then raw_value end) as habitable_area_ha,
    max(case when indicator_code = 'B1104' then raw_value end) as major_lake_area_ha,
    max(case when indicator_code = 'B1105' then raw_value end) as forest_and_field_area_ha,
    max(case when indicator_code = 'B1106' then raw_value end) as forest_area_ha,
    max(case when indicator_code = 'B1107' then raw_value end) as grassland_area_ha,
    max(case when indicator_code = 'B1108' then raw_value end) as nature_conservation_area_ha,
    max(case when indicator_code = 'B1201' then raw_value end) as assessed_land_total_m2,
    max(case when indicator_code = 'B120101' then raw_value end) as assessed_land_paddy_m2,
    max(case when indicator_code = 'B120102' then raw_value end) as assessed_land_field_m2,
    max(case when indicator_code = 'B120103' then raw_value end) as assessed_land_residential_m2,
    max(case when indicator_code = 'B120104' then raw_value end) as assessed_land_mountain_m2,
    max(case when indicator_code = 'B120105' then raw_value end) as assessed_land_pasture_m2,
    max(case when indicator_code = 'B120106' then raw_value end) as assessed_land_wasteland_m2,
    max(case when indicator_code = 'B120107' then raw_value end) as assessed_land_other_m2,
    max(case when indicator_code = 'B1303' then raw_value end) as afforestation_area_ha
from source
group by area_code, area_name, year_code, survey_year
