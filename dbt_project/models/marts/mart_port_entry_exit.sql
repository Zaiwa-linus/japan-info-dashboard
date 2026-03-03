-- [責務] 港別出入国者データを Evidence 用に出力する
-- [ユニークキー] traveler_type_code, direction_code, port_code, year
-- [入力] int_port_entry_exit

select
    traveler_type_code,
    traveler_type_name,
    direction_code,
    direction_name,
    port_code,
    port_name,
    year,
    raw_value
from {{ ref('int_port_entry_exit') }}
