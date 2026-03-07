-- [責務] 平成27年基準の県内総生産額（総額＋第1/2/3次産業別）を都道府県別に横持ちにする
-- [ユニークキー] area_code, year
-- [入力] stg_economic_base

select
    area_code,
    area_name,
    cast(left(cast(year_code as varchar), 4) as integer) as year,
    max(case when indicator_code = 'C1121' then raw_value end) as gdp_total_value,
    max(case when indicator_code = 'C1125' then raw_value end) as gdp_primary_value,
    max(case when indicator_code = 'C1126' then raw_value end) as gdp_secondary_value,
    max(case when indicator_code = 'C1127' then raw_value end) as gdp_tertiary_value
from {{ ref('stg_economic_base') }}
where area_code != '00000'
    and indicator_code in ('C1121', 'C1125', 'C1126', 'C1127')
    and raw_value is not null
group by area_code, area_name, year_code
