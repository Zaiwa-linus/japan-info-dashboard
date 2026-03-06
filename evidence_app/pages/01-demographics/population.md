---
title: 都道府県別人口
sidebar_position: 2
---

人口推計（総務省）のデータを基に、都道府県別の人口を可視化しています。

---

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
    raw_value as population
from japan_stats.mart_population
where year_name = '${inputs.selected_year.value}'
order by area_code
```

```sql population_total
select
    area_name,
    area_code,
    sum(raw_value) as total_population
from japan_stats.mart_population
where year_name = '${inputs.selected_year.value}'
group by area_name, area_code
order by total_population desc
```

### 都道府県別 総人口マップ

<TileMap data={population_total} valueCol="total_population" fmt="num0" />

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
    sum(case when a.year_name = '2023年10月1日現在' then a.raw_value else 0 end) as pop_2023,
    sum(case when a.year_name = '2024年10月1日現在' then a.raw_value else 0 end) as pop_2024,
    sum(case when a.year_name = '2024年10月1日現在' then a.raw_value else 0 end)
    - sum(case when a.year_name = '2023年10月1日現在' then a.raw_value else 0 end) as change,
    round(
        (sum(case when a.year_name = '2024年10月1日現在' then a.raw_value else 0 end)
        - sum(case when a.year_name = '2023年10月1日現在' then a.raw_value else 0 end))
        / sum(case when a.year_name = '2023年10月1日現在' then a.raw_value else 0 end) * 100
    , 2) as change_pct
from japan_stats.mart_population a
group by a.area_name, a.area_code
order by change desc
```

## 前年比較（2023年 → 2024年）

<TileMap data={yoy_comparison} valueCol="change" fmt="num0" />

<DataTable data={yoy_comparison} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=pop_2023 title="2023年人口" fmt=num0 />
    <Column id=pop_2024 title="2024年人口" fmt=num0 />
    <Column id=change title="増減数" fmt=num0 />
    <Column id=change_pct title="増減率(%)" fmt=num2 />
</DataTable>

<LastRefreshed />

---

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 人口推計（総務省）</small>
