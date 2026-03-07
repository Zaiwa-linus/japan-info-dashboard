-- [責務] 犯罪統計の検挙率を都道府県別に提供する
-- [ユニークキー] area_code, year

select * from {{ ref('int_prep_wide_crime_rate') }}
