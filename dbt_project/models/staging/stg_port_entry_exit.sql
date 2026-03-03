-- 出入国管理統計 - 港別 出入国者
-- 統計表ID: 0003288041
-- description: data/0003288041/description.md

with source as (
    select * from {{ source('estat', '0003288041') }}
)

select
    "表章項目_code" as item_code,
    "表章項目" as item_name,
    "出入国者_code" as traveler_type_code,
    "出入国者" as traveler_type_name,
    "入国・出国_code" as direction_code,
    "入国・出国" as direction_name,
    "港_code" as port_code,
    "港" as port_name,
    "時間軸(年次)_code" as year_code,
    "時間軸(年次)" as year_name,
    unit as unit_name,
    try_cast(value as bigint) as raw_value
from source
