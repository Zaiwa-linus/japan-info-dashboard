-- [責務] 都道府県別の出生児数・死亡者数を抽出し、全国行・男女計行を除外する
-- [ユニークキー] birth_death_code, gender_code, nationality_code, area_code
-- [入力] stg_birth_death_by_prefecture

select
    birth_death_code,
    birth_death_name,
    gender_code,
    gender_name,
    nationality_code,
    nationality_name,
    area_code,
    area_name,
    year_code,
    year_name,
    unit_name,
    raw_value
from {{ ref('stg_birth_death_by_prefecture') }}
where area_name != '全国'
    and gender_name != '男女計'
    and raw_value is not null
