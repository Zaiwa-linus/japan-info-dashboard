-- 耐久消費財所有数量（二人以上の世帯）の都道府県別データ
-- 時代の変遷が見える家電・自動車・デジタル機器などの普及状況

select
    indicator_code,
    indicator_name,
    area_code,
    area_name,
    cast(left(cast(year_code as varchar), 4) as integer) as year,
    unit,
    value
from {{ ref('stg_household') }}
where indicator_code like 'L51%'
