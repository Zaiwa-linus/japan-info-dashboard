---
title: 貯蓄・負債（二人以上世帯）
sidebar_position: 11
---

県庁所在市別の二人以上世帯における年間収入・貯蓄現在高・負債現在高を可視化しています（2002-2024年）。

```sql years
select distinct year from japan_stats.mart_savings_debt order by year desc
```

<Dropdown data={years} name=selected_year value=year defaultValue={years[0].year} />

---

```sql savings_ranking
select area_code, area_name, savings_total_value as value
from japan_stats.mart_savings_debt
where year = ${inputs.selected_year.value}
    and savings_total_value is not null
order by value desc
```

```sql top3
select * from ${savings_ranking} limit 3
```

```sql bottom3
select * from ${savings_ranking} order by value asc limit 3
```

#### 貯蓄現在高 Top 3

<CardGrid>
    {#each top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.area_name}" value={row.value} fmt="num0" />
    {/each}
</CardGrid>

#### 貯蓄現在高 Bottom 3

<CardGrid>
    {#each bottom3 as row, i}
    <StatCard emoji={["1️⃣", "2️⃣", "3️⃣"][i]} title="{row.area_name}" value={row.value} fmt="num0" />
    {/each}
</CardGrid>

---

## 全国マップ

### 貯蓄現在高

<small>※ {inputs.selected_year.value}年・単位：万円</small>

<TileMap data={savings_ranking} fmt="num0" />

```sql debt_ranking
select area_code, area_name, debt_total_value as value
from japan_stats.mart_savings_debt
where year = ${inputs.selected_year.value}
    and debt_total_value is not null
order by value desc
```

### 負債現在高

<TileMap data={debt_ranking} fmt="num0" />

<details>
<summary>データテーブルを表示</summary>

```sql full_data
select area_code, area_name,
    annual_income_value,
    savings_total_value,
    debt_total_value
from japan_stats.mart_savings_debt
where year = ${inputs.selected_year.value}
order by area_code
```

<DataTable data={full_data} rows=all search=true>
    <Column id=area_name title="県庁所在市" />
    <Column id=annual_income_value title="年間収入（万円）" fmt=num0 />
    <Column id=savings_total_value title="貯蓄（万円）" fmt=num0 />
    <Column id=debt_total_value title="負債（万円）" fmt=num0 />
</DataTable>

</details>

---

## 都道府県別の推移

```sql prefectures
select distinct area_name, area_code
from japan_stats.mart_savings_debt
order by area_code
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都区部" />

```sql trend_data
select
    year,
    annual_income_value,
    savings_total_value,
    debt_total_value
from japan_stats.mart_savings_debt
where area_name = '${inputs.selected_pref.value}'
order by year
```

<LineChart
    data={trend_data}
    x=year
    y={["savings_total_value", "debt_total_value", "annual_income_value"]}
    seriesNames={["貯蓄現在高", "負債現在高", "年間収入"]}
    title="{inputs.selected_pref.value} の収入・貯蓄・負債 推移"
    yAxisTitle="万円"
    yFmt=num0
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 貯蓄・負債編（二人以上の世帯）</small>
