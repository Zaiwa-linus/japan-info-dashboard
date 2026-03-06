---
title: 小売業態別 販売動向
sidebar_position: 7
---

都道府県別の小売業態（コンビニ・ドラッグストア・家電量販店・ホームセンター）の月次販売額・店舗数を可視化しています。

```sql store_type_names
select distinct store_type_name from japan_stats.mart_retail_sales order by store_type_name
```

<Dropdown data={store_type_names} name=selected_store value=store_type_name defaultValue="コンビニ" />

---

```sql latest_month
select cast(year_month as varchar) as latest_year_month, period_raw_name as latest_period_name
from japan_stats.mart_retail_sales
where store_type_name = '${inputs.selected_store.value}'
    and sales_amount is not null
order by year_month desc
limit 1
```

```sql ranking
select area_code, area_name, sales_amount as value
from japan_stats.mart_retail_sales
where store_type_name = '${inputs.selected_store.value}'
    and cast(year_month as varchar) = '${latest_month[0].latest_year_month}'
    and sales_amount is not null
order by value desc
```

```sql top3
select * from ${ranking} limit 3
```

```sql bottom3
select * from ${ranking} order by value asc limit 3
```

#### {inputs.selected_store.value} 販売額 Top 3

<CardGrid>
    {#each top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.area_name}" value={row.value} />
    {/each}
</CardGrid>

#### {inputs.selected_store.value} 販売額 Bottom 3

<CardGrid>
    {#each bottom3 as row, i}
    <StatCard emoji={["1️⃣", "2️⃣", "3️⃣"][i]} title="{row.area_name}" value={row.value} />
    {/each}
</CardGrid>

---

## 全国マップ

<small>※ {latest_month[0].latest_period_name}データ</small>

<TileMap data={ranking} fmt="num0" />

<details>
<summary>データテーブルを表示</summary>

<DataTable data={ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=value title="販売額（百万円）" fmt=num0 />
</DataTable>

</details>

---

## 都道府県別の推移

```sql prefectures
select distinct area_name, area_code
from japan_stats.mart_retail_sales
order by area_code
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都" />

```sql trend_data
select year_month, sales_amount as value
from japan_stats.mart_retail_sales
where area_name = '${inputs.selected_pref.value}'
    and store_type_name = '${inputs.selected_store.value}'
    and sales_amount is not null
order by year_month
```

<LineChart
    data={trend_data}
    x=year_month
    y=value
    yAxisTitle="販売額（百万円）"
    yFmt=num0
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 商業動態統計調査</small>
