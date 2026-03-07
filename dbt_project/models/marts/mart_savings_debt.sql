-- [責務] 二人以上世帯の貯蓄・負債・年間収入を県庁所在市別に提供する
-- [ユニークキー] area_code, year

select * from {{ ref('int_prep_wide_savings_debt') }}
