-- 耐久消費財所有数量（二人以上の世帯）都道府県別マート
-- マスタから短縮名を結合し、ダッシュボード表示に適した形にする

select
    dg.indicator_code,
    dg.indicator_name,
    m.indicator_short_name,
    dg.area_code,
    dg.area_name,
    dg.year,
    dg.unit,
    dg.value
from {{ ref('int_durable_goods') }} as dg
left join {{ ref('int_master_household_indicator') }} as m
    on dg.indicator_code = m.indicator_code
