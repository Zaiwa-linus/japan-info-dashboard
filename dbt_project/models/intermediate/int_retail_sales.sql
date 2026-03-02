-- 商業動態統計 - 4業態の都道府県別月次データ（縦持ち）
-- コンビニ / 家電量販店 / ドラッグストア / ホームセンター
-- 月次データのみに絞り込み、増減率を除外

with unioned as (
    select * from {{ ref('stg_convenience_store_sales') }}
    union all
    select * from {{ ref('stg_electronics_store_sales') }}
    union all
    select * from {{ ref('stg_drugstore_sales') }}
    union all
    select * from {{ ref('stg_home_center_sales') }}
)

select
    unit_code,
    unit_name,
    header_item_code,
    header_item_name,
    side_item_code,
    side_item_name,
    area_code,
    area_name,
    time_code,
    time_name,
    store_type,
    value
from unioned
-- 月次データ: 末尾4桁がMMDD形式で前半2桁=後半2桁（例: 0101, 0202, ..., 1212）
where substring(time_code, 7, 2) = substring(time_code, 9, 2)
    and substring(time_code, 7, 2) between '01' and '12'
    -- 販売額等のみ（増減率を除外）
    and side_item_name = '販売額等'
