-- 社会・人口統計体系 - Ｌ 家計（都道府県別）
-- 統計表ID: 0000010112

with source as (
    select * from {{ source('estat', '0000010112') }}
)

select
    "観測値_code" as observation_code,
    "観測値" as observation,
    "Ｌ　家計_code" as indicator_code,
    "Ｌ　家計" as indicator_name,
    "地域_code" as area_code,
    "地域" as area_name,
    "調査年_code" as year_code,
    "調査年" as year_name,
    unit,
    try_cast(value as double) as value
from source
