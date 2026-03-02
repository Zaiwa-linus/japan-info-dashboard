-- 出入国管理統計 - 国籍・地域別 入国目的別 新規入国外国人
-- 統計表ID: 0003288053

with source as (
    select * from {{ source('estat', '0003288053') }}
)

select
    "表章項目_code" as item_code,
    "表章項目" as item_name,
    "入国目的_code" as purpose_code,
    "入国目的" as purpose_name,
    "国籍・地域_code" as nationality_code,
    "国籍・地域" as nationality_name,
    "時間軸(年次)_code" as year_code,
    "時間軸(年次)" as year_name,
    unit,
    try_cast(value as bigint) as value
from source
