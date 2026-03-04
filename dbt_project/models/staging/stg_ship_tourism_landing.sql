-- 出入国管理統計 - 船舶観光上陸許可（国籍・港別）
-- 統計表ID: 0003288314
-- description: data/0003288314/description.md

with source as (
    select * from {{ source('estat', '0003288314') }}
)

select
    "表章項目_code" as item_code,
    "表章項目" as item_name,
    "国籍・地域_code" as nationality_code,
    "国籍・地域" as nationality_name,
    "港_code" as port_code,
    "港" as port_name,
    "時間軸(年次)_code" as year_code,
    "時間軸(年次)" as year_name,
    unit as unit_name,
    try_cast(value as bigint) as raw_value
from source
