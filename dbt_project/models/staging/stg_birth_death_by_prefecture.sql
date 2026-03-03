-- 人口推計 - 都道府県別 出生児数・死亡者数
-- 統計表ID: 0004026265
-- description: data/0004026265/description.md

with source as (
    select * from {{ source('estat', '0004026265') }}
)

select
    "表章項目_code" as item_code,
    "表章項目" as item_name,
    "出生児数・死亡者数_code" as birth_death_code,
    "出生児数・死亡者数" as birth_death_name,
    "男女別_code" as gender_code,
    "男女別" as gender_name,
    "日本人・外国人_code" as nationality_code,
    "日本人・外国人" as nationality_name,
    "全国・都道府県_code" as area_code,
    "全国・都道府県" as area_name,
    "時間軸（年間）_code" as year_code,
    "時間軸（年間）" as year_name,
    unit as unit_name,
    try_cast(value as bigint) as raw_value
from source
