-- [責務] 都道府県レベルの転入者データを抽出し、市区町村行を除外する
-- [ユニークキー] current_address_code, nationality_code, previous_address_code
-- [入力] stg_population_migration

select
    current_address_code,
    current_address_name,
    nationality_code,
    nationality_name,
    previous_address_code,
    previous_address_name,
    year_name,
    raw_value
from {{ ref('stg_population_migration') }}
where right(current_address_code, 3) = '000'
    and (previous_address_code = '00005' or right(previous_address_code, 3) = '000')
    and (previous_address_code = '00005' or current_address_code != previous_address_code)
    and raw_value is not null
