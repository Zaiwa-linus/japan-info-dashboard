-- [責務] 港別出入国者データに年を付与し、集約行を除外する
-- [ユニークキー] traveler_type_code, direction_code, port_code, year
-- [入力] stg_port_entry_exit

select
    traveler_type_code,
    traveler_type_name,
    direction_code,
    direction_name,
    port_code,
    port_name,
    cast(left(cast(year_code as varchar), 4) as integer) as year,
    year_name,
    raw_value
from {{ ref('stg_port_entry_exit') }}
where port_code != '50000'
    and raw_value is not null
