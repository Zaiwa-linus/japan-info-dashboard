-- [責務] 消費者物価地域差指数を都道府県レベルに絞り、10大費目＋総合を横持ちにする
-- [ユニークキー] area_code, year

select
    area_code,
    area_name,
    cast(left(cast(year_code as varchar), 4) as integer) as year,
    max(case when expense_category_code = '00010' then raw_value end) as cpi_total_value,
    max(case when expense_category_code = '00020' then raw_value end) as cpi_food_value,
    max(case when expense_category_code = '00030' then raw_value end) as cpi_housing_value,
    max(case when expense_category_code = '00040' then raw_value end) as cpi_utilities_value,
    max(case when expense_category_code = '00050' then raw_value end) as cpi_furniture_value,
    max(case when expense_category_code = '00060' then raw_value end) as cpi_clothing_value,
    max(case when expense_category_code = '00070' then raw_value end) as cpi_medical_value,
    max(case when expense_category_code = '00080' then raw_value end) as cpi_transport_value,
    max(case when expense_category_code = '00090' then raw_value end) as cpi_education_value,
    max(case when expense_category_code = '00100' then raw_value end) as cpi_culture_value,
    max(case when expense_category_code = '00110' then raw_value end) as cpi_misc_value
from {{ ref('stg_consumer_price_index') }}
where area_code like '__000'
    and area_code not in ('00000')
    and area_code not like '000%'
    and expense_category_name != '(参考)家賃を除く総合'
    and raw_value is not null
group by area_code, area_name, year_code
