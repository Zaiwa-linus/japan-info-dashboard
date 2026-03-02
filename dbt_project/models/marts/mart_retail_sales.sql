-- 商業動態統計 - 4業態の都道府県別月次販売額・店舗数マート（横持ち）

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
    max(case
        when header_item_name in ('販売額', '販売額等') and unit_name = '百万円'
        then value
    end) as sales_amount,
    max(case
        when header_item_name = '店舗数'
            or (header_item_name in ('販売額等') and unit_name = '店')
        then value
    end) as store_count
from {{ ref('int_retail_sales') }}
group by
    area_code, area_name, store_type,
    time_code, time_name
