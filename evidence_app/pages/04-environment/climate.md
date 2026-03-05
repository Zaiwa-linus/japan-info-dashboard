---
title: 気候
sidebar_position: 1
---

<style>
    .tile-map {
        display: grid;
        grid-template-columns: repeat(13, minmax(40px, 52px));
        gap: 3px;
        justify-content: center;
        margin: 1rem auto;
    }
    .tile {
        background: transparent;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        padding: 4px 6px;
        display: flex;
        flex-direction: column;
        align-items: center;
        min-height: 44px;
    }
    .tile-selected {
        box-shadow: 0 0 0 1.5px #1e40af;
    }
    .tile-name {
        font-size: 0.55rem;
        opacity: 0.7;
        align-self: flex-start;
        line-height: 1;
    }
    .tile-value {
        font-size: 0.75rem;
        font-weight: 600;
        margin-top: auto;
        margin-bottom: auto;
    }
</style>

都道府県の気候データを指標別に比較・分析できます。

```sql prefectures
select distinct area_name, area_code
from japan_stats.mart_climate
order by area_code
```

```sql indicators
select distinct
    indicator_code,
    indicator_label || '（' || unit || '）' as indicator_display
from japan_stats.mart_climate
order by indicator_code
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都" />
<Dropdown data={indicators} name=selected_indicator value=indicator_code label=indicator_display defaultValue="B4101" />

---

```sql selected_info
select distinct indicator_label, unit
from japan_stats.mart_climate
where indicator_code = '${inputs.selected_indicator.value}'
```

## {inputs.selected_pref.value} の推移

```sql trend_data
select make_date(cast(year as integer), 1, 1) as year_date, value
from japan_stats.mart_climate
where area_name = '${inputs.selected_pref.value}'
    and indicator_code = '${inputs.selected_indicator.value}'
order by year_date
```

<LineChart
    data={trend_data}
    x=year_date
    xFmt=yyyy
    y=value
    yAxisTitle="{selected_info[0].indicator_label}（{selected_info[0].unit}）"
    yFmt=num1
/>

---

## 全国マップ

```sql map_year
select max(year) as latest_year
from japan_stats.mart_climate
where indicator_code = '${inputs.selected_indicator.value}'
```

<small>※ {map_year[0].latest_year}年データ</small>

```sql tile_data
with positions(area_code, grid_row, grid_col) as (
    values
    ('01000', 1, 12),
    ('02000', 3, 12), ('03000', 4, 12), ('04000', 5, 12), ('05000', 4, 11),
    ('06000', 5, 11), ('07000', 6, 12), ('08000', 7, 13), ('09000', 7, 12),
    ('10000', 7, 11), ('11000', 8, 12), ('12000', 8, 13), ('13000', 9, 12),
    ('14000', 10, 12), ('15000', 6, 10), ('16000', 6, 9),  ('17000', 6, 8),
    ('18000', 6, 7),  ('19000', 8, 11), ('20000', 7, 10), ('21000', 7, 9),
    ('22000', 9, 11), ('23000', 8, 10), ('24000', 8, 9),  ('25000', 7, 8),
    ('26000', 7, 7),  ('27000', 8, 7),  ('28000', 7, 6),  ('29000', 8, 8),
    ('30000', 9, 8),  ('31000', 6, 5),  ('32000', 6, 4),  ('33000', 7, 5),
    ('34000', 7, 4),  ('35000', 6, 3),  ('36000', 9, 6),  ('37000', 9, 5),
    ('38000', 9, 4),  ('39000', 10, 5), ('40000', 7, 3),  ('41000', 7, 2),
    ('42000', 7, 1),  ('43000', 8, 2),  ('44000', 8, 3),  ('45000', 9, 3),
    ('46000', 9, 2),  ('47000', 9, 1)
)
select
    p.grid_row,
    p.grid_col,
    c.area_name,
    case
        when c.area_name = '北海道' then '北海道'
        when right(c.area_name, 1) in ('都', '府', '県')
        then left(c.area_name, length(c.area_name) - 1)
        else c.area_name
    end as short_name,
    c.value,
    c.unit,
    case when c.area_name = '${inputs.selected_pref.value}' then 1 else 0 end as is_selected,
    case
        when c.value is not null and max(c.value) over () != min(c.value) over ()
        then (c.value - min(c.value) over ()) / (max(c.value) over () - min(c.value) over ())
        else 0
    end as ratio
from positions p
left join japan_stats.mart_climate c
    on p.area_code = c.area_code
    and c.indicator_code = '${inputs.selected_indicator.value}'
    and c.year = (select max(year) from japan_stats.mart_climate where indicator_code = '${inputs.selected_indicator.value}')
```

<div class="tile-map">
{#each tile_data as tile}
    <div class="tile{tile.is_selected ? ' tile-selected' : ''}" style="grid-row: {tile.grid_row}; grid-column: {tile.grid_col}; border-color: {tile.value != null ? `rgb(${Math.round(255 - tile.ratio * 196)}, ${Math.round(255 - tile.ratio * 125)}, ${Math.round(255 - tile.ratio * 9)})` : '#e2e8f0'}; border-width: {tile.is_selected ? '2.5px' : '1.5px'};">
        <span class="tile-name">{tile.short_name}</span>
        <span class="tile-value">{tile.value != null ? Number(tile.value).toFixed(1) : '-'}</span>
    </div>
{/each}
</div>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a></small>
