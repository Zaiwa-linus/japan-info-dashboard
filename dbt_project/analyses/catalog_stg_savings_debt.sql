-- stg_savings_debt の列ごとのユニーク値カタログ
-- 使い方: dbt show --select catalog_stg_savings_debt --limit 1000
-- 目的: accepted_values テスト作成のための保有値一覧

-- item_code / item_name
select
    'item' as column_group,
    item_code as code,
    item_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_savings_debt') }}
group by item_code, item_name

union all

-- category_code / category_name
select
    'category' as column_group,
    category_code as code,
    category_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_savings_debt') }}
group by category_code, category_name

union all

-- household_type_code / household_type_name
select
    'household_type' as column_group,
    household_type_code as code,
    household_type_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_savings_debt') }}
group by household_type_code, household_type_name

union all

-- area_code / area_name
select
    'area' as column_group,
    area_code as code,
    area_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_savings_debt') }}
group by area_code, area_name

union all

-- year_code / year_name
select
    'year' as column_group,
    year_code as code,
    year_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_savings_debt') }}
group by year_code, year_name

union all

-- unit
select
    'unit' as column_group,
    cast(null as varchar) as code,
    cast(null as varchar) as name,
    unit,
    count(*) as row_count
from {{ ref('stg_savings_debt') }}
group by unit

order by column_group, code
