-- [責務] 都道府県別・男女別の総人口を抽出し、全国行と不要な分類を除外する
-- [ユニークキー] area_code, gender_code, year_code
-- [入力] stg_population

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
from {{ ref('stg_population') }}
where population_type_name = '人口'
    and gender_name in ('男', '女')
    and area_name != '全国'
    and population_category_name = '総人口'
    and year_name in ('2023年10月1日現在', '2024年10月1日現在')
