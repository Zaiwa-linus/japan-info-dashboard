---
title: 犯罪統計
sidebar_position: 12
---

都道府県別の刑法犯認知件数・検挙件数・検挙人員・検挙率を可視化しています（2006-2016年）。

```sql years
select distinct year from japan_stats.mart_crime_counts order by year desc
```

<Dropdown data={years} name=selected_year value=year defaultValue={years[0].year} />

---

## 認知件数

```sql crime_ranking
select area_code, area_name, recognized_count_value as value
from japan_stats.mart_crime_counts
where year = ${inputs.selected_year.value}
    and recognized_count_value is not null
order by value desc
```

```sql top3
select * from ${crime_ranking} limit 3
```

```sql bottom3
select * from ${crime_ranking} order by value asc limit 3
```

#### 認知件数 Top 3

<CardGrid>
    {#each top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.area_name}" value={row.value} fmt="num0" />
    {/each}
</CardGrid>

#### 認知件数 Bottom 3

<CardGrid>
    {#each bottom3 as row, i}
    <StatCard emoji={["1️⃣", "2️⃣", "3️⃣"][i]} title="{row.area_name}" value={row.value} fmt="num0" />
    {/each}
</CardGrid>

### 全国マップ（認知件数）

<small>※ {inputs.selected_year.value}年データ</small>

<TileMap data={crime_ranking} fmt="num0" />

<details>
<summary>データテーブルを表示</summary>

```sql crime_full
select
    c.area_code,
    c.area_name,
    c.recognized_count_value,
    c.arrested_count_value,
    c.arrested_persons_value,
    r.arrest_rate_value
from japan_stats.mart_crime_counts c
left join japan_stats.mart_crime_rate r
    on c.area_code = r.area_code and c.year = r.year
where c.year = ${inputs.selected_year.value}
order by c.recognized_count_value desc
```

<DataTable data={crime_full} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=recognized_count_value title="認知件数" fmt=num0 />
    <Column id=arrested_count_value title="検挙件数" fmt=num0 />
    <Column id=arrested_persons_value title="検挙人員" fmt=num0 />
    <Column id=arrest_rate_value title="検挙率（%）" fmt=num1 />
</DataTable>

</details>

---

## 検挙率マップ

```sql rate_ranking
select area_code, area_name, arrest_rate_value as value
from japan_stats.mart_crime_rate
where year = ${inputs.selected_year.value}
    and arrest_rate_value is not null
order by value desc
```

<small>※ {inputs.selected_year.value}年データ</small>

<TileMap data={rate_ranking} fmt="num1" />

---

## 都道府県別の推移

```sql prefectures
select distinct area_name, area_code
from japan_stats.mart_crime_counts
order by area_code
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都" />

```sql trend_counts
select year, recognized_count_value, arrested_count_value, arrested_persons_value
from japan_stats.mart_crime_counts
where area_name = '${inputs.selected_pref.value}'
order by year
```

<LineChart
    data={trend_counts}
    x=year
    y={["recognized_count_value", "arrested_count_value"]}
    seriesNames={["認知件数", "検挙件数"]}
    title="{inputs.selected_pref.value} の認知件数・検挙件数 推移"
    yAxisTitle="件"
    yFmt=num0
/>

```sql trend_rate
select year, arrest_rate_value
from japan_stats.mart_crime_rate
where area_name = '${inputs.selected_pref.value}'
order by year
```

<LineChart
    data={trend_rate}
    x=year
    y=arrest_rate_value
    title="{inputs.selected_pref.value} の検挙率 推移"
    yAxisTitle="検挙率（%）"
    yFmt=num1
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 犯罪統計</small>
