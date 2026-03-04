-- [責務] 自然環境データ（土地・公園・植生・気候）を都道府県×年で結合する
-- [ユニークキー] area_code, year
-- [入力] int_wide_natural_env_land, int_wide_natural_env_parks, int_wide_natural_env_vegetation, int_wide_natural_env_climate

select
    land.area_code,
    land.area_name,
    land.year,
    -- 土地
    land.total_area_excl_northern_ha,
    land.total_area_incl_northern_ha,
    land.habitable_area_ha,
    land.major_lake_area_ha,
    land.forest_and_field_area_ha,
    land.forest_area_ha,
    land.grassland_area_ha,
    land.nature_conservation_area_ha,
    land.assessed_land_total_m2,
    land.assessed_land_paddy_m2,
    land.assessed_land_field_m2,
    land.assessed_land_residential_m2,
    land.assessed_land_mountain_m2,
    land.assessed_land_pasture_m2,
    land.assessed_land_wasteland_m2,
    land.assessed_land_other_m2,
    land.afforestation_area_ha,
    -- 公園
    parks.natural_park_area_ha,
    parks.prefectural_park_count,
    parks.prefectural_park_area_ha,
    parks.national_park_area_ha,
    parks.quasi_national_park_area_ha,
    -- 植生自然度
    veg.vegetation_naturalness_1_pct,
    veg.vegetation_naturalness_2_pct,
    veg.vegetation_naturalness_3_pct,
    veg.vegetation_naturalness_4_pct,
    veg.vegetation_naturalness_5_pct,
    veg.vegetation_naturalness_6_pct,
    veg.vegetation_naturalness_7_pct,
    veg.vegetation_naturalness_8_pct,
    veg.vegetation_naturalness_9_pct,
    veg.vegetation_naturalness_10_pct,
    -- 気候
    climate.avg_temperature_celsius,
    climate.max_temperature_celsius,
    climate.min_temperature_celsius,
    climate.clear_sky_days,
    climate.cloudy_days,
    climate.rainy_days,
    climate.snow_days,
    climate.sunshine_hours,
    climate.precipitation_mm,
    climate.max_snow_depth_cm,
    climate.avg_relative_humidity_pct,
    climate.min_relative_humidity_pct
from {{ ref('int_wide_natural_env_land') }} as land
left join {{ ref('int_wide_natural_env_parks') }} as parks
    on land.area_code = parks.area_code and land.year = parks.year
left join {{ ref('int_wide_natural_env_vegetation') }} as veg
    on land.area_code = veg.area_code and land.year = veg.year
left join {{ ref('int_wide_natural_env_climate') }} as climate
    on land.area_code = climate.area_code and land.year = climate.year
where land.area_code != '00000'
