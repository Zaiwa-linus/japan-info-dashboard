-- 商業動態統計調査 - ホームセンター 都道府県別販売額等
-- 統計表ID: 0004032511
-- description: data/0004032511/description.md

with source as (
    select * from {{ source('estat', '0004032511') }}
)

select
    "単位_db_code" as unit_code,
    "単位_db" as unit_name,
    "表頭_集計項目_db_code" as header_item_code,
    "表頭_集計項目_db" as header_item_name,
    "表側_集計項目_db_code" as side_item_code,
    "表側_集計項目_db" as side_item_name,
    "都道府県_code" as area_code,
    "都道府県" as area_name,
    cast("時間軸_db_code" as varchar) as time_code,
    "時間軸_db" as time_name,
    'ホームセンター' as store_type_name,
    try_cast(value as double) as raw_value
from source
