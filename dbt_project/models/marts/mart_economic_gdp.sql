-- [責務] 平成27年基準の県内総生産（GDP）を都道府県別に提供する
-- [ユニークキー] area_code, year

select * from {{ ref('int_prep_wide_economic_gdp_h27') }}
