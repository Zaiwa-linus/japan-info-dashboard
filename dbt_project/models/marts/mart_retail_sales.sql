-- [責務] 4業態の月次販売データを都道府県×年月×業態のワイドテーブルに変換する
-- [ユニークキー] area_code, store_type_name, period_raw_code
-- [入力] int_prep_retail_sales

select
    area_code,
    area_name,
    store_type_name,
    cast(substring(period_raw_code, 1, 4) as integer) as year,
    cast(substring(period_raw_code, 7, 2) as integer) as month,
    make_date(
        cast(substring(period_raw_code, 1, 4) as integer),
        cast(substring(period_raw_code, 7, 2) as integer),
        1
    ) as year_month,
    period_raw_name,
    max(case
        when header_item_name in ('販売額', '販売額等') and unit_name = '百万円'
        then raw_value
    end) as sales_amount,
    max(case
        when header_item_name = '店舗数'
            or (header_item_name in ('販売額等') and unit_name = '店')
        then raw_value
    end) as store_count
from {{ ref('int_prep_retail_sales') }}
group by
    area_code, area_name, store_type_name,
    period_raw_code, period_raw_name
