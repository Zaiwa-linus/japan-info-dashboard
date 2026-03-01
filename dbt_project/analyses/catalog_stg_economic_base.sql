-- stg_economic_base の列ごとのユニーク値カタログ
-- 使い方: dbt show --select catalog_stg_economic_base --limit 1000
-- 目的: accepted_values テスト作成のための保有値一覧

-- observation_code / observation
select
    'observation' as column_group,
    observation_code as code,
    observation as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_economic_base') }}
group by observation_code, observation

union all

-- indicator_code / indicator_name
select
    'indicator' as column_group,
    indicator_code as code,
    indicator_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_economic_base') }}
group by indicator_code, indicator_name

union all

-- area_code / area_name
select
    'area' as column_group,
    area_code as code,
    area_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_economic_base') }}
group by area_code, area_name

union all

-- year_code / year_name
select
    'year' as column_group,
    year_code as code,
    year_name as name,
    cast(null as varchar) as unit,
    count(*) as row_count
from {{ ref('stg_economic_base') }}
group by year_code, year_name

union all

-- unit
select
    'unit' as column_group,
    cast(null as varchar) as code,
    cast(null as varchar) as name,
    unit,
    count(*) as row_count
from {{ ref('stg_economic_base') }}
group by unit

order by column_group, code
