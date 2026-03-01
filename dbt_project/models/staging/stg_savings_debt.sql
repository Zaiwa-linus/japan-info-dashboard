-- 家計調査 - 貯蓄・負債（都市階級・地方・県庁所在市別）
-- 統計表ID: 0002210008

with source as (
    select * from {{ source('estat', '0002210008') }}
)

select
    "表章項目_code" as item_code,
    "表章項目" as item_name,
    "貯蓄・負債_code" as category_code,
    "貯蓄・負債" as category_name,
    "世帯区分_code" as household_type_code,
    "世帯区分" as household_type_name,
    "地域区分_code" as area_code,
    "地域区分" as area_name,
    "時間軸（年次）_code" as year_code,
    "時間軸（年次）" as year_name,
    unit,
    try_cast(value as double) as value
from source
