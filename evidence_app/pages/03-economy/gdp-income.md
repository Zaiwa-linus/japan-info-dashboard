---
title: 県内総生産・県民所得
sidebar_position: 9
---

都道府県別の県内総生産（GDP）と県民所得の推移を可視化しています（平成27年基準、2011-2021年度）。

```sql years
select distinct year from japan_stats.mart_economic_gdp order by year desc
```

<Dropdown data={years} name=selected_year value=year defaultValue={years[0].year} />

---

## 県内総生産（GDP）

```sql gdp_ranking
select area_code, area_name, gdp_total_value as value
from japan_stats.mart_economic_gdp
where year = ${inputs.selected_year.value}
    and gdp_total_value is not null
order by value desc
```

```sql top3_gdp
select * from ${gdp_ranking} limit 3
```

```sql bottom3_gdp
select * from ${gdp_ranking} order by value asc limit 3
```

#### GDP Top 3

<CardGrid>
    {#each top3_gdp as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.area_name}" value={row.value} fmt="num0" />
    {/each}
</CardGrid>

#### GDP Bottom 3

<CardGrid>
    {#each bottom3_gdp as row, i}
    <StatCard emoji={["1️⃣", "2️⃣", "3️⃣"][i]} title="{row.area_name}" value={row.value} fmt="num0" />
    {/each}
</CardGrid>

### 全国マップ（県内総生産）

<small>※ {inputs.selected_year.value}年度・単位：百万円</small>

<TileMap data={gdp_ranking} fmt="num0" />

<details>
<summary>データテーブルを表示</summary>

<DataTable data={gdp_ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=value title="県内総生産（百万円）" fmt=num0 />
</DataTable>

</details>

---

## 産業別構成

```sql prefectures
select distinct area_name, area_code
from japan_stats.mart_economic_gdp
order by area_code
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都" />

```sql gdp_sector
select
    year,
    gdp_total_value,
    gdp_primary_value,
    gdp_secondary_value,
    gdp_tertiary_value
from japan_stats.mart_economic_gdp
where area_name = '${inputs.selected_pref.value}'
order by year
```

<AreaChart
    data={gdp_sector}
    x=year
    y={["gdp_primary_value", "gdp_secondary_value", "gdp_tertiary_value"]}
    seriesNames={["第1次産業", "第2次産業", "第3次産業"]}
    title="{inputs.selected_pref.value} の産業別GDP推移"
    yAxisTitle="百万円"
    yFmt=num0
    type=stacked
/>

---

## 県民所得

```sql income_ranking
select area_code, area_name, income_per_capita_value as value
from japan_stats.mart_economic_income
where year = ${inputs.selected_year.value}
    and income_per_capita_value is not null
order by value desc
```

### 全国マップ（一人当たり県民所得）

<small>※ {inputs.selected_year.value}年度・単位：千円</small>

<TileMap data={income_ranking} fmt="num0" />

<details>
<summary>データテーブルを表示</summary>

<DataTable data={income_ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=value title="一人当たり県民所得（千円）" fmt=num0 />
</DataTable>

</details>

### 県民所得の推移

```sql income_trend
select
    year,
    income_total_value,
    compensation_value,
    property_income_value,
    corporate_income_value
from japan_stats.mart_economic_income
where area_name = '${inputs.selected_pref.value}'
order by year
```

<AreaChart
    data={income_trend}
    x=year
    y={["compensation_value", "property_income_value", "corporate_income_value"]}
    seriesNames={["雇用者報酬", "財産所得", "企業所得"]}
    title="{inputs.selected_pref.value} の県民所得内訳推移"
    yAxisTitle="百万円"
    yFmt=num0
    type=stacked
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 県民経済計算</small>
