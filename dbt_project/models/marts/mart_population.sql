-- 都道府県別・男女別の総人口マート

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
    unit,
    value
from {{ ref('int_population') }}
