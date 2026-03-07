---
title: 課税対象所得・納税義務者数
sidebar_position: 10
---

都道府県別の課税対象所得と納税義務者数の推移を可視化しています（1985-2024年）。

```sql years
select distinct year from japan_stats.mart_economic_tax order by year desc
```

<Dropdown data={years} name=selected_year value=year defaultValue={years[0].year} />

---

## 課税対象所得

```sql tax_ranking
select area_code, area_name, taxable_income_value as value
from japan_stats.mart_economic_tax
where year = ${inputs.selected_year.value}
    and taxable_income_value is not null
order by value desc
```

```sql top3
select * from ${tax_ranking} limit 3
```

```sql bottom3
select * from ${tax_ranking} order by value asc limit 3
```

#### 課税対象所得 Top 3

<CardGrid>
    {#each top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.area_name}" value={row.value} fmt="num0" />
    {/each}
</CardGrid>

#### 課税対象所得 Bottom 3

<CardGrid>
    {#each bottom3 as row, i}
    <StatCard emoji={["1️⃣", "2️⃣", "3️⃣"][i]} title="{row.area_name}" value={row.value} fmt="num0" />
    {/each}
</CardGrid>

### 全国マップ（課税対象所得）

<small>※ {inputs.selected_year.value}年・単位：千円</small>

<TileMap data={tax_ranking} fmt="num0" />

<details>
<summary>データテーブルを表示</summary>

<DataTable data={tax_ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=value title="課税対象所得（千円）" fmt=num0 />
</DataTable>

</details>

---

## 都道府県別の推移

```sql prefectures
select distinct area_name, area_code
from japan_stats.mart_economic_tax
order by area_code
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都" />

```sql tax_trend
select
    year,
    taxable_income_value,
    taxpayer_count_value
from japan_stats.mart_economic_tax
where area_name = '${inputs.selected_pref.value}'
order by year
```

<LineChart
    data={tax_trend}
    x=year
    y=taxable_income_value
    title="{inputs.selected_pref.value} の課税対象所得 推移"
    yAxisTitle="千円"
    yFmt=num0
/>

<LineChart
    data={tax_trend}
    x=year
    y=taxpayer_count_value
    title="{inputs.selected_pref.value} の納税義務者数 推移"
    yAxisTitle="人"
    yFmt=num0
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 社会・人口統計体系</small>
