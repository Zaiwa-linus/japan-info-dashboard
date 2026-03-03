-- [責務] 都道府県別の転入者データを Evidence 用に出力する
-- [ユニークキー] current_address_code, nationality_code, previous_address_code
-- [入力] int_prep_population_migration

select
    current_address_code,
    current_address_name,
    nationality_code,
    nationality_name,
    previous_address_code,
    previous_address_name,
    year_name,
    raw_value
from {{ ref('int_prep_population_migration') }}
