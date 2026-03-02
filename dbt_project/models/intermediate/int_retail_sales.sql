-- 商業動態統計 - 4業態の都道府県別月次販売額・店舗数（横持ち）
-- コンビニ / 家電量販店 / ドラッグストア / ホームセンター

with unioned as (
    select * from {{ ref('stg_convenience_store_sales') }}
    union all
    select * from {{ ref('stg_electronics_store_sales') }}
    union all
    select * from {{ ref('stg_drugstore_sales') }}
    union all
    select * from {{ ref('stg_home_center_sales') }}
),

monthly_only as (
    select *
    from unioned
    -- 月次データ: 末尾4桁がMMDD形式で前半2桁=後半2桁（例: 0101, 0202, ..., 1212）
    where substring(time_code, 7, 2) = substring(time_code, 9, 2)
        and substring(time_code, 7, 2) between '01' and '12'
        -- 販売額等のみ（増減率を除外）
        and side_item_name = '販売額等'
)

select
    area_code,
    area_name,
    store_type,
    cast(substring(time_code, 1, 4) as integer) as year,
    cast(substring(time_code, 7, 2) as integer) as month,
    make_date(
        cast(substring(time_code, 1, 4) as integer),
        cast(substring(time_code, 7, 2) as integer),
        1
    ) as year_month,
    time_name,
    max(case when header_item_name = '販売額' or (header_item_name = '販売額等' and unit_name = '百万円') then value end) as sales_amount,
    max(case when header_item_name = '店舗数' or (header_item_name = '販売額等' and unit_name != '百万円') then value end) as store_count
from monthly_only
group by
    area_code, area_name, store_type,
    time_code, time_name
