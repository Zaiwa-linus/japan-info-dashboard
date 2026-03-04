-- 犯罪統計 - 都道府県別 刑法犯 認知・検挙件数
-- 統計表ID: 0003195002
-- description: data/0003195002/description.md

with source as (
    select * from {{ source('estat', '0003195002') }}
)

select
    "認知・検挙件数・検挙人員_code" as crime_metric_code,
    "認知・検挙件数・検挙人員" as crime_metric_name,
    "管区警察局_code" as police_district_code,
    "管区警察局" as police_district_name,
    "時間軸(年次)_code" as year_code,
    "時間軸(年次)" as year_name,
    unit as unit_name,
    try_cast(value as double) as raw_value
from source
