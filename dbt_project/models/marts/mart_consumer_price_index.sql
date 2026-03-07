-- [責務] 消費者物価地域差指数の都道府県別横持ちデータを提供する
-- [ユニークキー] area_code, year

select * from {{ ref('int_prep_wide_consumer_price_index') }}
