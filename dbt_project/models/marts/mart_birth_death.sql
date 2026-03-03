-- [責務] 都道府県別の出生児数・死亡者数を Evidence 用に出力する
-- [ユニークキー] birth_death_code, gender_code, nationality_code, area_code
-- [入力] int_prep_birth_death

select
    birth_death_code,
    birth_death_name,
    gender_code,
    gender_name,
    nationality_code,
    nationality_name,
    area_code,
    area_name,
    year_name,
    unit_name,
    raw_value
from {{ ref('int_prep_birth_death') }}
