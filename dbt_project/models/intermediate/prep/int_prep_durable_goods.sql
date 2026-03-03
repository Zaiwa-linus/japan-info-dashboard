-- [責務] 家計統計から耐久消費財（L51系）の指標のみを抽出し、年を整数化する
-- [ユニークキー] indicator_code, area_code, year
-- [入力] stg_household

select
    indicator_code,
    indicator_name,
    area_code,
    area_name,
    cast(left(cast(year_code as varchar), 4) as integer) as year,
    unit_name,
    raw_value
from {{ ref('stg_household') }}
where indicator_code like 'L51%'
