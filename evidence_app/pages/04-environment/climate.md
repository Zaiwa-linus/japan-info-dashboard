---
title: 気候
sidebar_position: 1
---

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
select area_code, area_name, value
from japan_stats.mart_climate
where indicator_code = '${inputs.selected_indicator.value}'
    and year = (select max(year) from japan_stats.mart_climate where indicator_code = '${inputs.selected_indicator.value}')
```

<TileMap data={tile_data} selected="{inputs.selected_pref.value}" />

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a></small>
