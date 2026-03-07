-- [責務] 課税対象所得・納税義務者数を都道府県別に提供する
-- [ユニークキー] area_code, year

select * from {{ ref('int_prep_wide_economic_tax') }}
