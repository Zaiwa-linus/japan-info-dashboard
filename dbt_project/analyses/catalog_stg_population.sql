-- stg_population の列ごとのユニーク値カタログ
-- 使い方: dbt show --select catalog_stg_population --limit 1000
-- 目的: accepted_values テスト作成のための保有値一覧

-- item_code / item_name
select
    'item' as column_group,
    item_code as code,
    item_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_population') }}
group by item_code, item_name

union all

-- population_type_code / population_type_name
select
    'population_type' as column_group,
    population_type_code as code,
    population_type_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_population') }}
group by population_type_code, population_type_name

union all

-- gender_code / gender_name
select
    'gender' as column_group,
    gender_code as code,
    gender_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_population') }}
group by gender_code, gender_name

union all

-- population_category_code / population_category_name
select
    'population_category' as column_group,
    population_category_code as code,
    population_category_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_population') }}
group by population_category_code, population_category_name

union all

-- area_code / area_name
select
    'area' as column_group,
    area_code as code,
    area_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_population') }}
group by area_code, area_name

union all

-- year_code / year_name
select
    'year' as column_group,
    year_code as code,
    year_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_population') }}
group by year_code, year_name

union all

-- unit
select
    'unit' as column_group,
    cast(null as varchar) as code,
    cast(null as varchar) as name,
    unit,
    count(*) as row_count
from {{ ref('stg_population') }}
group by unit

order by column_group, code
