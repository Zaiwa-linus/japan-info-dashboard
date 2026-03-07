-- [責務] 犯罪統計の検挙率を都道府県レベルに絞り込む（率は合計不可のため件数と分離）
-- [ユニークキー] area_code, year

select
    police_district_code as area_code,
    police_district_name as area_name,
    cast(left(cast(year_code as varchar), 4) as integer) as year,
    raw_value as arrest_rate_value
from {{ ref('stg_crime_statistics') }}
where police_district_code like '__000'
    and police_district_code != '00000'
    and crime_metric_code = 120
    and raw_value is not null
