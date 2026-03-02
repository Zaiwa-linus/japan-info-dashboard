---
title: 耐久消費財の普及状況
---

# 耐久消費財の普及状況

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
    value
from japan_stats.mart_durable_goods
where area_name = '${inputs.selected_area.value}'
    and value is not null
order by year
```

<LineChart
    data={trend}
    x=year
    y=value
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
    value
from japan_stats.mart_durable_goods
where indicator_short_name = '${inputs.selected_item.value}'
    and year = ${inputs.selected_year.value}
    and area_name != '全国'
    and value is not null
order by area_code
```

<AreaMap
    data={map_data}
    geoJsonUrl=japan_prefectures.geojson
    geoId=nam_ja
    areaCol=area_name
    value=value
    valueFmt=num0
    title="{inputs.selected_item.value}（{inputs.selected_year.value}年）"
    height=500
    legendType=scalar
    tooltip={[{id: 'area_name', title: '都道府県'}, {id: 'value', title: '千世帯あたり', fmt: 'num0'}]}
/>

---

## 都道府県ランキング

```sql ranking
select
    area_name,
    value
from japan_stats.mart_durable_goods
where indicator_short_name = '${inputs.selected_item.value}'
    and year = ${inputs.selected_year.value}
    and value is not null
order by value desc
```

<DataTable data={ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=value title="千世帯あたり所有数量" fmt=num0 />
</DataTable>

<LastRefreshed />

---

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> / 地図データ出典：<a href="https://www.gsi.go.jp/kankyochiri/gm_japan_e.html" target="_blank">地球地図日本</a>（国土地理院）</small>
