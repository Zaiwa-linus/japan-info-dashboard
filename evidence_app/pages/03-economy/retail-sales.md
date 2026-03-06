---
title: 小売業態別 販売動向
sidebar_position: 7
---

都道府県別の小売業態（コンビニ・ドラッグストア・家電量販店・ホームセンター）の月次販売額・店舗数を可視化しています。データは e-Stat（政府統計の総合窓口）の商業動態統計調査（2024年）から取得しています。

---

## 業態別 月次販売額の推移

```sql prefectures
select distinct area_name from japan_stats.mart_retail_sales order by area_code
```

<Dropdown data={prefectures} name=selected_area value=area_name defaultValue="東京都" />

```sql monthly_trend
select
    year_month,
    store_type_name,
    sales_amount
from japan_stats.mart_retail_sales
where area_name = '${inputs.selected_area.value}'
    and sales_amount is not null
order by year_month, store_type_name
```

<LineChart
    data={monthly_trend}
    x=year_month
    y=sales_amount
    series=store_type_name
    title="{inputs.selected_area.value} の業態別 月次販売額"
    yAxisTitle="販売額（百万円）"
/>

---

## 都道府県別 販売額マップ

```sql store_type_names
select distinct store_type_name from japan_stats.mart_retail_sales order by store_type_name
```

```sql months
select distinct cast(year_month as varchar) as year_month, period_raw_name from japan_stats.mart_retail_sales order by year_month desc
```

<Dropdown data={store_type_names} name=selected_store value=store_type_name defaultValue="コンビニ" />
<Dropdown data={months} name=selected_month value=year_month label=period_raw_name />

```sql map_data
select
    area_name,
    area_code,
    sales_amount
from japan_stats.mart_retail_sales
where store_type_name = '${inputs.selected_store.value}'
    and cast(year_month as varchar) = '${inputs.selected_month.value}'
    and sales_amount is not null
order by area_code
```

<TileMap data={map_data} valueCol="sales_amount" fmt="num0" />

---

## 都道府県別 販売額ランキング

```sql ranking
select
    area_name,
    sales_amount,
    store_count
from japan_stats.mart_retail_sales
where store_type_name = '${inputs.selected_store.value}'
    and cast(year_month as varchar) = '${inputs.selected_month.value}'
    and sales_amount is not null
order by sales_amount desc
```

<BarChart
    data={ranking}
    x=area_name
    y=sales_amount
    title="{inputs.selected_store.value} 都道府県別 販売額ランキング（{inputs.selected_month.label}）"
    yAxisTitle="販売額（百万円）"
    swapXY=true
    sort=false
/>

<DataTable data={ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=sales_amount title="販売額（百万円）" fmt=num0 />
    <Column id=store_count title="店舗数" fmt=num0 />
</DataTable>

---

## 業態別 店舗数の推移

```sql store_trend
select
    year_month,
    store_type_name,
    store_count
from japan_stats.mart_retail_sales
where area_name = '${inputs.selected_area.value}'
    and store_count is not null
order by year_month, store_type_name
```

<LineChart
    data={store_trend}
    x=year_month
    y=store_count
    series=store_type_name
    title="{inputs.selected_area.value} の業態別 店舗数の推移"
    yAxisTitle="店舗数"
/>

---

## 業態構成比（年間販売額）

```sql composition
select
    store_type_name,
    sum(sales_amount) as total_sales
from japan_stats.mart_retail_sales
where area_name = '${inputs.selected_area.value}'
    and year = 2024
    and sales_amount is not null
group by store_type_name
order by total_sales desc
```

<ECharts config={
    {
        tooltip: {trigger: 'item', formatter: '{b}: {c}百万円 ({d}%)'},
        series: [{
            type: 'pie',
            radius: ['40%', '70%'],
            data: composition.map(row => ({name: row.store_type_name, value: row.total_sales})),
            label: {formatter: '{b}\n{d}%'}
        }]
    }
}/>

<LastRefreshed />

---

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 商業動態統計調査</small>
