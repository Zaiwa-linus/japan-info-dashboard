---
title: 耐久消費財の普及状況
sidebar_position: 8
---

都道府県別の耐久消費財所有数量（二人以上の世帯、千世帯あたり）を可視化しています。データは e-Stat（政府統計の総合窓口）から取得しています。

---

## 品目別 時系列推移

```sql areas
select distinct area_name from japan_stats.mart_durable_goods order by area_name
```

<Dropdown data={areas} name=selected_area value=area_name defaultValue="全国" />

```sql trend
select
    indicator_short_name,
    year,
    raw_value
from japan_stats.mart_durable_goods
where area_name = '${inputs.selected_area.value}'
    and raw_value is not null
order by year
```

<LineChart
    data={trend}
    x=year
    y=raw_value
    series=indicator_short_name
    title="{inputs.selected_area.value} の耐久消費財所有数量の推移"
    yAxisTitle="千世帯あたり所有数量"
    xAxisTitle="年"
/>

---

## 都道府県別マップ

```sql items
select distinct indicator_short_name from japan_stats.mart_durable_goods order by indicator_short_name
```

```sql years
select distinct year from japan_stats.mart_durable_goods order by year desc
```

<Dropdown data={items} name=selected_item value=indicator_short_name defaultValue="スマートフォン" />
<Dropdown data={years} name=selected_year value=year defaultValue={2014} />

```sql map_data
select
    area_name,
    area_code,
    raw_value
from japan_stats.mart_durable_goods
where indicator_short_name = '${inputs.selected_item.value}'
    and year = ${inputs.selected_year.value}
    and area_name != '全国'
    and raw_value is not null
order by area_code
```

<TileMap data={map_data} valueCol="raw_value" fmt="num0" />

---

## 都道府県ランキング

```sql ranking
select
    area_name,
    raw_value
from japan_stats.mart_durable_goods
where indicator_short_name = '${inputs.selected_item.value}'
    and year = ${inputs.selected_year.value}
    and raw_value is not null
order by raw_value desc
```

<DataTable data={ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=raw_value title="千世帯あたり所有数量" fmt=num0 />
</DataTable>

<LastRefreshed />

---

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a></small>
