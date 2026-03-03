-- 住民基本台帳人口移動報告 - 移動前の住所地別転入者数
-- 統計表ID: 0004026702
-- description: data/0004026702/description.md

with source as (
    select * from {{ source('estat', '0004026702') }}
)

select
    "表章項目_code" as item_code,
    "表章項目" as item_name,
    "移動後の住所地（現住地）2020～_code" as current_address_code,
    "移動後の住所地（現住地）2020～" as current_address_name,
    "国籍_code" as nationality_code,
    "国籍" as nationality_name,
    "移動前の住所地（前住地）2020～_code" as previous_address_code,
    "移動前の住所地（前住地）2020～" as previous_address_name,
    "時間軸_code" as year_code,
    "時間軸" as year_name,
    unit as unit_name,
    try_cast(value as bigint) as raw_value
from source
