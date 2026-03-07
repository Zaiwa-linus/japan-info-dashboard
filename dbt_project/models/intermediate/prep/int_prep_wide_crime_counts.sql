-- [責務] 犯罪統計の件数・人員系指標を都道府県レベルに絞り、横持ちにする
-- [ユニークキー] area_code, year

select
    police_district_code as area_code,
    police_district_name as area_name,
    cast(left(cast(year_code as varchar), 4) as integer) as year,
    max(case when crime_metric_code = 100 then raw_value end) as recognized_count_value,
    max(case when crime_metric_code = 110 then raw_value end) as arrested_count_value,
    max(case when crime_metric_code = 130 then raw_value end) as arrested_persons_value
from {{ ref('stg_crime_statistics') }}
where police_district_code like '__000'
    and police_district_code != '00000'
    and crime_metric_code in (100, 110, 130)
    and raw_value is not null
group by police_district_code, police_district_name, year_code
