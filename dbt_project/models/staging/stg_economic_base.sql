-- 社会・人口統計体系 - Ｃ 経済基盤（都道府県別）
-- 統計表ID: 0000010103
-- description: data/0000010103/description.md

with source as (
    select * from {{ source('estat', '0000010103') }}
)

select
    "観測値_code" as observation_code,
    "観測値" as observation_name,
    "Ｃ　経済基盤_code" as indicator_code,
    "Ｃ　経済基盤" as indicator_name,
    "地域_code" as area_code,
    "地域" as area_name,
    "調査年_code" as year_code,
    "調査年" as year_name,
    unit as unit_name,
    try_cast(value as double) as raw_value
from source
