-- [責務] 4業態の月次販売データを統合し、月次データのみに絞り込む
-- [ユニークキー] area_code, store_type_name, period_raw_code, header_item_code, unit_code
-- [入力] stg_convenience_store_sales, stg_electronics_store_sales, stg_drugstore_sales, stg_home_center_sales

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
    period_raw_code,
    period_raw_name,
    store_type_name,
    raw_value
from unioned
-- 月次データ: 末尾4桁がMMDD形式で前半2桁=後半2桁（例: 0101, 0202, ..., 1212）
where substring(period_raw_code, 7, 2) = substring(period_raw_code, 9, 2)
    and substring(period_raw_code, 7, 2) between '01' and '12'
    -- 販売額等のみ（増減率を除外）
    and side_item_name = '販売額等'
