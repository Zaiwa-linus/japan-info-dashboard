-- [責務] 課税対象所得・納税義務者数を都道府県別に横持ちにする（同一期間1985-2024）
-- [ユニークキー] area_code, year
-- [入力] stg_economic_base

select
    area_code,
    area_name,
    cast(left(cast(year_code as varchar), 4) as integer) as year,
    max(case when indicator_code = 'C120110' then raw_value end) as taxable_income_value,
    max(case when indicator_code = 'C120120' then raw_value end) as taxpayer_count_value
from {{ ref('stg_economic_base') }}
where area_code != '00000'
    and indicator_code in ('C120110', 'C120120')
    and raw_value is not null
group by area_code, area_name, year_code
