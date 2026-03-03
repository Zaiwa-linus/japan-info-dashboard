-- [責務] 都道府県別・男女別の総人口を Evidence 用に出力する
-- [ユニークキー] area_code, gender_code, year_code
-- [入力] int_prep_population

select
    item_code,
    item_name,
    population_type_code,
    population_type_name,
    gender_code,
    gender_name,
    population_category_code,
    population_category_name,
    area_code,
    area_name,
    year_code,
    year_name,
    unit_name,
    raw_value
from {{ ref('int_prep_population') }}
