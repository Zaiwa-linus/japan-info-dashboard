-- [責務] 二人以上世帯の貯蓄・負債・年間収入の主要指標を県庁所在市別に横持ちにする
-- [ユニークキー] area_code, year
-- [入力] stg_savings_debt

select
    area_code,
    area_name,
    cast(left(cast(year_code as varchar), 4) as integer) as year,
    max(case when category_code = '011' then raw_value end) as annual_income_value,
    max(case when category_code = '012' then raw_value end) as savings_total_value,
    max(case when category_code = '028' then raw_value end) as debt_total_value
from {{ ref('stg_savings_debt') }}
where area_code like '__003'
    and household_type_code = '03'
    and category_code in ('011', '012', '028')
    and raw_value is not null
group by area_code, area_name, year_code
