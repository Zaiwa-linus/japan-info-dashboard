-- [責務] 耐久消費財データにマスタの短縮名を結合し、ダッシュボード表示に適した形にする
-- [ユニークキー] indicator_code, area_code, year
-- [入力] int_prep_durable_goods, int_master_household_indicator

select
    dg.indicator_code,
    dg.indicator_name,
    m.indicator_short_name,
    dg.area_code,
    dg.area_name,
    dg.year,
    dg.unit_name,
    dg.raw_value
from {{ ref('int_prep_durable_goods') }} as dg
left join {{ ref('int_master_household_indicator') }} as m
    on dg.indicator_code = m.indicator_code
