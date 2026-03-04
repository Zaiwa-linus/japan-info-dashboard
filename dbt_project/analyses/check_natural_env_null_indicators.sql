-- [目的] mart_natural_environment の各指標について、最新年データのnull件数を確認する
-- 全都道府県(47)でnullの指標はデータ未収録のため、ダッシュボード表示から除外する

with latest as (
    select *,
        row_number() over (partition by area_code order by year desc) as rn
    from {{ ref('mart_natural_environment') }}
),

latest_data as (
    select * from latest where rn = 1
)

select indicator, non_null, null_count
from (
    -- 土地
    select 'total_area_incl_northern_ha' as indicator, count(total_area_incl_northern_ha) as non_null, count(*) - count(total_area_incl_northern_ha) as null_count from latest_data
    union all select 'habitable_area_ha', count(habitable_area_ha), count(*) - count(habitable_area_ha) from latest_data
    union all select 'major_lake_area_ha', count(major_lake_area_ha), count(*) - count(major_lake_area_ha) from latest_data
    union all select 'forest_and_field_area_ha', count(forest_and_field_area_ha), count(*) - count(forest_and_field_area_ha) from latest_data
    union all select 'forest_area_ha', count(forest_area_ha), count(*) - count(forest_area_ha) from latest_data
    union all select 'grassland_area_ha', count(grassland_area_ha), count(*) - count(grassland_area_ha) from latest_data
    union all select 'nature_conservation_area_ha', count(nature_conservation_area_ha), count(*) - count(nature_conservation_area_ha) from latest_data
    union all select 'afforestation_area_ha', count(afforestation_area_ha), count(*) - count(afforestation_area_ha) from latest_data
    -- 固定資産税評価地
    union all select 'assessed_land_total_m2', count(assessed_land_total_m2), count(*) - count(assessed_land_total_m2) from latest_data
    union all select 'assessed_land_paddy_m2', count(assessed_land_paddy_m2), count(*) - count(assessed_land_paddy_m2) from latest_data
    union all select 'assessed_land_field_m2', count(assessed_land_field_m2), count(*) - count(assessed_land_field_m2) from latest_data
    union all select 'assessed_land_residential_m2', count(assessed_land_residential_m2), count(*) - count(assessed_land_residential_m2) from latest_data
    union all select 'assessed_land_mountain_m2', count(assessed_land_mountain_m2), count(*) - count(assessed_land_mountain_m2) from latest_data
    union all select 'assessed_land_pasture_m2', count(assessed_land_pasture_m2), count(*) - count(assessed_land_pasture_m2) from latest_data
    union all select 'assessed_land_wasteland_m2', count(assessed_land_wasteland_m2), count(*) - count(assessed_land_wasteland_m2) from latest_data
    union all select 'assessed_land_other_m2', count(assessed_land_other_m2), count(*) - count(assessed_land_other_m2) from latest_data
    -- 気候
    union all select 'avg_temperature_celsius', count(avg_temperature_celsius), count(*) - count(avg_temperature_celsius) from latest_data
    union all select 'max_temperature_celsius', count(max_temperature_celsius), count(*) - count(max_temperature_celsius) from latest_data
    union all select 'min_temperature_celsius', count(min_temperature_celsius), count(*) - count(min_temperature_celsius) from latest_data
    union all select 'clear_sky_days', count(clear_sky_days), count(*) - count(clear_sky_days) from latest_data
    union all select 'cloudy_days', count(cloudy_days), count(*) - count(cloudy_days) from latest_data
    union all select 'rainy_days', count(rainy_days), count(*) - count(rainy_days) from latest_data
    union all select 'snow_days', count(snow_days), count(*) - count(snow_days) from latest_data
    union all select 'sunshine_hours', count(sunshine_hours), count(*) - count(sunshine_hours) from latest_data
    union all select 'precipitation_mm', count(precipitation_mm), count(*) - count(precipitation_mm) from latest_data
    union all select 'max_snow_depth_cm', count(max_snow_depth_cm), count(*) - count(max_snow_depth_cm) from latest_data
    union all select 'avg_relative_humidity_pct', count(avg_relative_humidity_pct), count(*) - count(avg_relative_humidity_pct) from latest_data
    union all select 'min_relative_humidity_pct', count(min_relative_humidity_pct), count(*) - count(min_relative_humidity_pct) from latest_data
    -- 公園
    union all select 'natural_park_area_ha', count(natural_park_area_ha), count(*) - count(natural_park_area_ha) from latest_data
    union all select 'prefectural_park_count', count(prefectural_park_count), count(*) - count(prefectural_park_count) from latest_data
    union all select 'prefectural_park_area_ha', count(prefectural_park_area_ha), count(*) - count(prefectural_park_area_ha) from latest_data
    union all select 'national_park_area_ha', count(national_park_area_ha), count(*) - count(national_park_area_ha) from latest_data
    union all select 'quasi_national_park_area_ha', count(quasi_national_park_area_ha), count(*) - count(quasi_national_park_area_ha) from latest_data
) sub
order by null_count desc, indicator
