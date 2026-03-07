---
title: 消費者物価地域差指数
sidebar_position: 8
---

都道府県別の消費者物価地域差指数（10大費目＋総合）を可視化しています。全国平均を100とした相対的な物価水準を示します。

```sql years
select distinct year from japan_stats.mart_consumer_price_index order by year desc
```

<Dropdown data={years} name=selected_year value=year defaultValue={years[0].year} />

---

```sql ranking
select area_code, area_name, cpi_total_value as value
from japan_stats.mart_consumer_price_index
where year = ${inputs.selected_year.value}
    and cpi_total_value is not null
order by value desc
```

```sql top3
select * from ${ranking} limit 3
```

```sql bottom3
select * from ${ranking} order by value asc limit 3
```

#### 総合CPI Top 3（物価が高い）

<CardGrid>
    {#each top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.area_name}" value={row.value} fmt="num1" />
    {/each}
</CardGrid>

#### 総合CPI Bottom 3（物価が低い）

<CardGrid>
    {#each bottom3 as row, i}
    <StatCard emoji={["1️⃣", "2️⃣", "3️⃣"][i]} title="{row.area_name}" value={row.value} fmt="num1" />
    {/each}
</CardGrid>

---

## 全国マップ（総合CPI）

<small>※ {inputs.selected_year.value}年データ</small>

<TileMap data={ranking} fmt="num1" />

<details>
<summary>データテーブルを表示</summary>

<DataTable data={ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=value title="総合CPI" fmt=num1 />
</DataTable>

</details>

---

## 費目別比較

```sql prefectures
select distinct area_name, area_code
from japan_stats.mart_consumer_price_index
order by area_code
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都" />

```sql cpi_breakdown
select
    area_name,
    year,
    cpi_total_value,
    cpi_food_value,
    cpi_housing_value,
    cpi_utilities_value,
    cpi_furniture_value,
    cpi_clothing_value,
    cpi_medical_value,
    cpi_transport_value,
    cpi_education_value,
    cpi_culture_value,
    cpi_misc_value
from japan_stats.mart_consumer_price_index
where area_name = '${inputs.selected_pref.value}'
    and year = ${inputs.selected_year.value}
```

```sql cpi_unpivot
select '総合' as category, cpi_total_value as value from ${cpi_breakdown}
union all select '食料', cpi_food_value from ${cpi_breakdown}
union all select '住居', cpi_housing_value from ${cpi_breakdown}
union all select '光熱・水道', cpi_utilities_value from ${cpi_breakdown}
union all select '家具・家事用品', cpi_furniture_value from ${cpi_breakdown}
union all select '被服及び履物', cpi_clothing_value from ${cpi_breakdown}
union all select '保健医療', cpi_medical_value from ${cpi_breakdown}
union all select '交通・通信', cpi_transport_value from ${cpi_breakdown}
union all select '教育', cpi_education_value from ${cpi_breakdown}
union all select '教養娯楽', cpi_culture_value from ${cpi_breakdown}
union all select '諸雑費', cpi_misc_value from ${cpi_breakdown}
```

<BarChart
    data={cpi_unpivot}
    x=category
    y=value
    title="{inputs.selected_pref.value} の費目別CPI（{inputs.selected_year.value}年）"
    yAxisTitle="指数（全国平均=100）"
    swapXY=true
    sort=false
    yFmt=num1
    yMin=85
/>

---

## 総合CPIの推移

```sql cpi_trend
select year, cpi_total_value as value
from japan_stats.mart_consumer_price_index
where area_name = '${inputs.selected_pref.value}'
order by year
```

<LineChart
    data={cpi_trend}
    x=year
    y=value
    title="{inputs.selected_pref.value} の総合CPI 推移"
    yAxisTitle="指数（全国平均=100）"
    yFmt=num1
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 消費者物価地域差指数</small>
