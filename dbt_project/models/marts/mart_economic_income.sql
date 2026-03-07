-- [責務] 平成27年基準の県民所得を都道府県別に提供する
-- [ユニークキー] area_code, year

select * from {{ ref('int_prep_wide_economic_income_h27') }}
