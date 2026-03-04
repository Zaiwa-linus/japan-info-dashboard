-- 社会・人口統計体系 - Ｂ 自然環境（都道府県別）
with source as (
    select * from {{ source('estat', '0000010102') }}
)

select
    "観測値_code" as observation_code,
    "観測値" as observation_name,
    "Ｂ　自然環境_code" as indicator_code,
    "Ｂ　自然環境" as indicator_name,
    "地域_code" as area_code,
    "地域" as area_name,
    "調査年_code" as year_code,
    "調査年" as year_name,
    cast(left(cast("調査年_code" as varchar), 4) as integer) as year,
    unit as unit_name,
    try_cast(value as double) as raw_value
from source
