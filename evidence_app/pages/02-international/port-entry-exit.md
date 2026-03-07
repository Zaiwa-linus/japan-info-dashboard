---
title: 空港・港別 出入国者数
sidebar_position: 6
---


出入国管理統計（法務省）のデータを基に、空港・港別の出入国者数を可視化しています。1997年〜2024年の時系列データを収録しています。

---

## 年次推移（全港合計）

```sql yearly_total
select
    year,
    sum(raw_value) as total_travelers
from japan_stats.mart_port_entry_exit
group by year
order by year
```

<LineChart
    data={yearly_total}
    x=year
    y=total_travelers
    title="出入国者数 総数の年次推移"
    yAxisTitle="出入国者数（人）"
    xAxisTitle="年"
    yFmt=num0
/>

コロナ禍（2020〜2021年）で激減した後、2023年から急速に回復し、2024年には約1億人に達しています。

---

## 主要空港・港ランキング

```sql years
select distinct year from japan_stats.mart_port_entry_exit order by year desc
```

<Dropdown data={years} name=selected_year value=year defaultValue={years[0].year} />

```sql top_ports
select
    port_name,
    sum(raw_value) as total_travelers
from japan_stats.mart_port_entry_exit
where year = ${inputs.selected_year.value}
group by port_name
order by total_travelers desc
limit 20
```

<BarChart
    data={top_ports}
    x=port_name
    y=total_travelers
    title="空港・港別 出入国者数 Top 20（{inputs.selected_year.value}年）"
    yAxisTitle="出入国者数（人）"
    swapXY=true
    sort=false
    yFmt=num0
/>

<DataTable data={top_ports} rows=all>
    <Column id=port_name title="空港・港" />
    <Column id=total_travelers title="出入国者数" fmt=num0 />
</DataTable>

---

## 日本人 vs 外国人 構成比（主要空港）

```sql by_traveler_type
select
    port_name,
    traveler_type_name,
    sum(raw_value) as total_travelers
from japan_stats.mart_port_entry_exit
where traveler_type_code in (110, 120)
    and year = ${inputs.selected_year.value}
    and port_name in (
        select port_name
        from japan_stats.mart_port_entry_exit
        where year = ${inputs.selected_year.value}
        group by port_name
        order by sum(raw_value) desc
        limit 15
    )
group by port_name, traveler_type_name
order by port_name, traveler_type_name
```

<BarChart
    data={by_traveler_type}
    x=port_name
    y=total_travelers
    series=traveler_type_name
    title="主要空港・港 日本人 vs 外国人（{inputs.selected_year.value}年）"
    yAxisTitle="出入国者数（人）"
    type=stacked100
    swapXY=true
    yFmt=num0
/>

---

## 主要空港の年次推移（コロナ前後の回復比較）

```sql top5_trend
select
    year,
    port_name,
    sum(raw_value) as total_travelers
from japan_stats.mart_port_entry_exit
where port_name in (
        select port_name
        from japan_stats.mart_port_entry_exit
        where year = 2024
        group by port_name
        order by sum(raw_value) desc
        limit 5
    )
group by year, port_name
order by year
```

<LineChart
    data={top5_trend}
    x=year
    y=total_travelers
    series=port_name
    title="主要空港 出入国者数の年次推移（Top 5）"
    yAxisTitle="出入国者数（人）"
    xAxisTitle="年"
    yFmt=num0
/>

---

## 入国者 vs 出国者

```sql direction_comparison
select
    port_name,
    direction_name,
    sum(raw_value) as total_travelers
from japan_stats.mart_port_entry_exit
where year = ${inputs.selected_year.value}
    and port_name in (
        select port_name
        from japan_stats.mart_port_entry_exit
        where year = ${inputs.selected_year.value}
        group by port_name
        order by sum(raw_value) desc
        limit 15
    )
group by port_name, direction_name
order by port_name, direction_name
```

<BarChart
    data={direction_comparison}
    x=port_name
    y=total_travelers
    series=direction_name
    title="主要空港・港 入国者 vs 出国者（{inputs.selected_year.value}年）"
    yAxisTitle="出入国者数（人）"
    type=grouped
    swapXY=true
    yFmt=num0
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 出入国管理統計（法務省）</small>
