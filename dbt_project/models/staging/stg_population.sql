-- 人口推計 - 都道府県・男女別人口
-- 統計表ID: 0004026264
-- description: data/0004026264/description.md

with source as (
    select * from {{ source('estat', '0004026264') }}
)

select
    "表章項目_code" as item_code,
    "表章項目" as item_name,
    "人口及び人口増減_code" as population_type_code,
    "人口及び人口増減" as population_type_name,
    "男女別_code" as gender_code,
    "男女別" as gender_name,
    "人口_code" as population_category_code,
    "人口" as population_category_name,
    "全国・都道府県_code" as area_code,
    "全国・都道府県" as area_name,
    "時間軸（年間）_code" as year_code,
    "時間軸（年間）" as year_name,
    unit as unit_name,
    try_cast(value as double) as raw_value
from source
