-- 小売物価統計調査 - 都道府県別 消費者物価地域差指数（10大費目別）
-- 統計表ID: 0003441258
-- description: data/0003441258/description.md

with source as (
    select * from {{ source('estat', '0003441258') }}
)

select
    "表章項目_code" as item_code,
    "表章項目" as item_name,
    "10大費目_code" as expense_category_code,
    "10大費目" as expense_category_name,
    "地域_code" as area_code,
    "地域" as area_name,
    "時間軸(年)_code" as year_code,
    "時間軸(年)" as year_name,
    unit as unit_name,
    try_cast(value as double) as raw_value
from source
