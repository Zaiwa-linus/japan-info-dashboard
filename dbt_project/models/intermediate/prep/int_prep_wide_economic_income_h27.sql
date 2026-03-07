-- [責務] 平成27年基準の県民所得・雇用者報酬を都道府県別に横持ちにする
-- [ユニークキー] area_code, year
-- [入力] stg_economic_base

select
    area_code,
    area_name,
    cast(left(cast(year_code as varchar), 4) as integer) as year,
    max(case when indicator_code = 'C1221' then raw_value end) as income_total_value,
    max(case when indicator_code = 'C122101' then raw_value end) as income_per_capita_value,
    max(case when indicator_code = 'C1222' then raw_value end) as compensation_value,
    max(case when indicator_code = 'C1223' then raw_value end) as property_income_value,
    max(case when indicator_code = 'C1224' then raw_value end) as corporate_income_value
from {{ ref('stg_economic_base') }}
where area_code != '00000'
    and indicator_code in ('C1221', 'C122101', 'C1222', 'C1223', 'C1224')
    and raw_value is not null
group by area_code, area_name, year_code
