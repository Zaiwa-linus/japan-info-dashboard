-- 都道府県別・男女別の総人口（全国を除く）
-- 2023年・2024年の10月1日時点の人口データ

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
from {{ ref('stg_population') }}
where population_type_name = '人口'
    and gender_name in ('男', '女')
    and area_name != '全国'
    and population_category_name = '総人口'
    and year_name in ('2023年10月1日現在', '2024年10月1日現在')
