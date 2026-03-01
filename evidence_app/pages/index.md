---
title: 日本の統計ダッシュボード
---

# 日本の統計ダッシュボード

都道府県別の人口データを可視化しています。データは e-Stat（政府統計の総合窓口）から取得しています。

---

## 都道府県別人口

```sql years
select distinct year_name from japan_stats.mart_population order by year_name
```

```sql genders
select distinct gender_name from japan_stats.mart_population order by gender_name
```

<Dropdown data={years} name=selected_year value=year_name />

```sql population_by_area
select
    area_name,
    gender_name,
    value as population
from japan_stats.mart_population
where year_name = '${inputs.selected_year.value}'
order by area_code
```

```sql population_total
select
    area_name,
    area_code,
    sum(value) as total_population
from japan_stats.mart_population
where year_name = '${inputs.selected_year.value}'
group by area_name, area_code
order by total_population desc
```

### 都道府県別 総人口ランキング（男女合計）

<BarChart
    data={population_total}
    x=area_name
    y=total_population
    title="都道府県別 総人口"
    xAxisTitle="都道府県"
    yAxisTitle="人口（人）"
    swapXY=true
    sort=false
    yFmt=num0
/>

### 都道府県別 男女別人口

<BarChart
    data={population_by_area}
    x=area_name
    y=population
    series=gender_name
    title="都道府県別 男女別人口"
    xAxisTitle="都道府県"
    yAxisTitle="人口（人）"
    type=stacked
    swapXY=true
    sort=false
    yFmt=num0
/>

### 人口データテーブル

<DataTable data={population_total} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=total_population title="総人口" fmt=num0 />
</DataTable>

---

```sql yoy_comparison
select
    a.area_name,
    a.area_code,
    sum(case when a.year_name = '2023年10月1日現在' then a.value else 0 end) as pop_2023,
    sum(case when a.year_name = '2024年10月1日現在' then a.value else 0 end) as pop_2024,
    sum(case when a.year_name = '2024年10月1日現在' then a.value else 0 end)
    - sum(case when a.year_name = '2023年10月1日現在' then a.value else 0 end) as change,
    round(
        (sum(case when a.year_name = '2024年10月1日現在' then a.value else 0 end)
        - sum(case when a.year_name = '2023年10月1日現在' then a.value else 0 end))
        / sum(case when a.year_name = '2023年10月1日現在' then a.value else 0 end) * 100
    , 2) as change_pct
from japan_stats.mart_population a
group by a.area_name, a.area_code
order by change desc
```

## 前年比較（2023年 → 2024年）

<BarChart
    data={yoy_comparison}
    x=area_name
    y=change
    title="都道府県別 人口増減（2023→2024）"
    xAxisTitle="都道府県"
    yAxisTitle="増減数（人）"
    swapXY=true
    sort=false
    yFmt=num0
/>

<DataTable data={yoy_comparison} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=pop_2023 title="2023年人口" fmt=num0 />
    <Column id=pop_2024 title="2024年人口" fmt=num0 />
    <Column id=change title="増減数" fmt=num0 />
    <Column id=change_pct title="増減率(%)" fmt=num2 />
</DataTable>

<LastRefreshed />
