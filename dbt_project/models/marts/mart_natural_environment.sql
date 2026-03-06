-- [責務] 自然環境データ（土地・公園・植生・気候）を都道府県×年で結合する
-- [ユニークキー] area_code, survey_year
-- [入力] int_prep_wide_natural_env_land_area, int_prep_wide_natural_env_land_lake, int_prep_wide_natural_env_land_forest, int_prep_wide_natural_env_land_assessed, int_prep_wide_natural_env_land_assessed_detail, int_prep_wide_natural_env_land_afforestation, int_prep_wide_natural_env_parks, int_prep_wide_natural_env_vegetation, int_prep_wide_natural_env_climate

select
    land.area_code,
    land.area_name,
    land.survey_year,
    -- 土地（基本面積）
    land.total_area_excl_northern_ha,
    land.total_area_incl_northern_ha,
    land.habitable_area_ha,
    land.nature_conservation_area_ha,
    -- 土地（湖沼）
    lake.major_lake_area_ha,
    -- 土地（林野）
    forest.forest_and_field_area_ha,
    forest.forest_area_ha,
    forest.grassland_area_ha,
    -- 土地（評価総地積・基本）
    assessed.assessed_land_total_m2,
    assessed.assessed_land_paddy_m2,
    assessed.assessed_land_field_m2,
    assessed.assessed_land_residential_m2,
    -- 土地（評価総地積・詳細）
    assessed_d.assessed_land_mountain_m2,
    assessed_d.assessed_land_pasture_m2,
    assessed_d.assessed_land_wasteland_m2,
    assessed_d.assessed_land_other_m2,
    -- 土地（造林）
    afforest.afforestation_area_ha,
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
    -- 気候（基本）
    clim.avg_temperature_celsius,
    clim.max_temperature_celsius,
    clim.min_temperature_celsius,
    clim.rainy_days,
    clim.sunshine_hours,
    clim.precipitation_mm,
    clim.avg_relative_humidity_pct,
    -- 気候（天候日数）
    clim_sky.clear_sky_days,
    clim_sky.snow_days,
    -- 気候（旧指標）
    clim_leg.cloudy_days,
    clim_leg.max_snow_depth_cm,
    clim_leg.min_relative_humidity_pct
from {{ ref('int_prep_wide_natural_env_land_area') }} as land
left join {{ ref('int_prep_wide_natural_env_land_lake') }} as lake
    on land.area_code = lake.area_code and land.survey_year = lake.survey_year
left join {{ ref('int_prep_wide_natural_env_land_forest') }} as forest
    on land.area_code = forest.area_code and land.survey_year = forest.survey_year
left join {{ ref('int_prep_wide_natural_env_land_assessed') }} as assessed
    on land.area_code = assessed.area_code and land.survey_year = assessed.survey_year
left join {{ ref('int_prep_wide_natural_env_land_assessed_detail') }} as assessed_d
    on land.area_code = assessed_d.area_code and land.survey_year = assessed_d.survey_year
left join {{ ref('int_prep_wide_natural_env_land_afforestation') }} as afforest
    on land.area_code = afforest.area_code and land.survey_year = afforest.survey_year
left join {{ ref('int_prep_wide_natural_env_parks') }} as parks
    on land.area_code = parks.area_code and land.survey_year = parks.survey_year
left join {{ ref('int_prep_wide_natural_env_vegetation') }} as veg
    on land.area_code = veg.area_code and land.survey_year = veg.survey_year
left join {{ ref('int_prep_wide_natural_env_climate_base') }} as clim
    on land.area_code = clim.area_code and land.survey_year = clim.survey_year
left join {{ ref('int_prep_wide_natural_env_climate_sky') }} as clim_sky
    on land.area_code = clim_sky.area_code and land.survey_year = clim_sky.survey_year
left join {{ ref('int_prep_wide_natural_env_climate_legacy') }} as clim_leg
    on land.area_code = clim_leg.area_code and land.survey_year = clim_leg.survey_year
