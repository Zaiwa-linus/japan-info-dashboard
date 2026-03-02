---
title: 日本の統計ダッシュボード
---

# 日本の統計ダッシュボード

都道府県別の統計データを可視化しています。データは e-Stat（政府統計の総合窓口）から取得しています。

- [耐久消費財の普及状況](/japan-info-dashboard/durable-goods)
- [小売業態別 販売動向](/japan-info-dashboard/retail-sales)
- [国籍別・入国目的別 新規入国外国人](/japan-info-dashboard/immigration)

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

### 都道府県別 総人口マップ

<AreaMap
    data={population_total}
    geoJsonUrl=japan_prefectures.geojson
    geoId=nam_ja
    areaCol=area_name
    value=total_population
    valueFmt=num0
    title="都道府県別 総人口"
    height=500
    legendType=scalar
    tooltip={[{id: 'area_name', title: '都道府県'}, {id: 'total_population', title: '人口', fmt: 'num0'}]}
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

<AreaMap
    data={yoy_comparison}
    geoJsonUrl=japan_prefectures.geojson
    geoId=nam_ja
    areaCol=area_name
    value=change
    valueFmt=num0
    title="都道府県別 人口増減（2023→2024）"
    height=500
    legendType=scalar
    tooltip={[{id: 'area_name', title: '都道府県'}, {id: 'change', title: '増減数', fmt: 'num0'}, {id: 'change_pct', title: '増減率(%)', fmt: 'num2'}]}
/>

<DataTable data={yoy_comparison} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=pop_2023 title="2023年人口" fmt=num0 />
    <Column id=pop_2024 title="2024年人口" fmt=num0 />
    <Column id=change title="増減数" fmt=num0 />
    <Column id=change_pct title="増減率(%)" fmt=num2 />
</DataTable>

<LastRefreshed />

---

<small>地図データ出典：<a href="https://www.gsi.go.jp/kankyochiri/gm_japan_e.html" target="_blank">地球地図日本</a>（国土地理院）</small>
