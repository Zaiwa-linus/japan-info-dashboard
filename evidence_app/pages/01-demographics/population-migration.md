---
title: 都道府県別 社会増減
sidebar_position: 4
---

住民基本台帳人口移動報告（総務省）のデータを基に、都道府県別の転入・転出による人口変動（社会増減）を可視化しています。2024年のデータを収録しています。

---

## 社会増減（転入 - 転出）

```sql net_migration
with inflow as (
    select
        current_address_code as area_code,
        current_address_name as area_name,
        sum(raw_value) as inflow
    from japan_stats.mart_population_migration
    where nationality_code = '60000'
        and previous_address_code != '00005'
        and current_address_code != previous_address_code
    group by current_address_code, current_address_name
),
outflow as (
    select
        previous_address_code as area_code,
        sum(raw_value) as outflow
    from japan_stats.mart_population_migration
    where nationality_code = '60000'
        and previous_address_code != '00005'
        and current_address_code != previous_address_code
    group by previous_address_code
)
select
    i.area_code,
    i.area_name,
    i.inflow,
    o.outflow,
    i.inflow - o.outflow as net_migration
from inflow i
join outflow o on i.area_code = o.area_code
order by net_migration desc
```

```sql net_top3
select * from ${net_migration} limit 3
```

```sql net_bottom3
select * from ${net_migration} order by net_migration asc limit 3
```

#### 社会増 Top 3

<CardGrid>
    {#each net_top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.area_name}" value={row.net_migration} />
    {/each}
</CardGrid>

#### 社会減 Top 3

<CardGrid>
    {#each net_bottom3 as row, i}
    <StatCard emoji={["1️⃣", "2️⃣", "3️⃣"][i]} title="{row.area_name}" value={row.net_migration} />
    {/each}
</CardGrid>

### 社会増減マップ

<DivergingTileMap data={net_migration} valueCol="net_migration" fmt="num0" />

<details>
<summary>データテーブルを表示</summary>

<DataTable data={net_migration} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=inflow title="転入者数" fmt=num0 />
    <Column id=outflow title="転出者数" fmt=num0 />
    <Column id=net_migration title="社会増減" fmt=num0 />
</DataTable>

</details>

---

## 都道府県別の詳細分析

```sql prefectures
select distinct current_address_name
from japan_stats.mart_population_migration
where previous_address_code = '00005'
    and nationality_code = '60000'
order by current_address_name
```

<Dropdown data={prefectures} name=selected_pref value=current_address_name defaultValue="東京都" />

### {inputs.selected_pref.value}の流入元 Top 3

```sql inflow_top3
select
    previous_address_name,
    raw_value as migrants
from japan_stats.mart_population_migration
where current_address_name = '${inputs.selected_pref.value}'
    and nationality_code = '60000'
    and previous_address_code != '00005'
    and current_address_code != previous_address_code
    and raw_value > 0
order by raw_value desc
limit 3
```

<CardGrid>
    {#each inflow_top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.previous_address_name}" value={row.migrants} />
    {/each}
</CardGrid>

### {inputs.selected_pref.value}の流出先 Top 3

```sql outflow_top3
select
    current_address_name,
    raw_value as migrants
from japan_stats.mart_population_migration
where previous_address_name = '${inputs.selected_pref.value}'
    and nationality_code = '60000'
    and previous_address_code != '00005'
    and current_address_code != previous_address_code
    and raw_value > 0
order by raw_value desc
limit 3
```

<CardGrid>
    {#each outflow_top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.current_address_name}" value={row.migrants} />
    {/each}
</CardGrid>

### {inputs.selected_pref.value}の日本人・外国人 転入比率

```sql nationality_pie
select
    nationality_name,
    raw_value as migrants
from japan_stats.mart_population_migration
where current_address_name = '${inputs.selected_pref.value}'
    and previous_address_code = '00005'
    and nationality_code in ('61000', '62000')
```

<ECharts config={
    {
        tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
        series: [
            {
                type: 'pie',
                radius: ['40%', '70%'],
                data: nationality_pie.map(row => ({ name: row.nationality_name, value: row.migrants })),
                label: { formatter: '{b}\n{d}%' }
            }
        ]
    }
} />

### {inputs.selected_pref.value}の転入元内訳（Top 20）

```sql migration_from
select
    previous_address_name,
    raw_value as migrants
from japan_stats.mart_population_migration
where current_address_name = '${inputs.selected_pref.value}'
    and nationality_code = '60000'
    and previous_address_code != '00005'
    and current_address_code != previous_address_code
    and raw_value > 0
order by raw_value desc
limit 20
```

<BarChart
    data={migration_from}
    x=previous_address_name
    y=migrants
    title="{inputs.selected_pref.value}への転入元 Top 20（2024年）"
    yAxisTitle="転入者数（人）"
    swapXY=true
    sort=false
    yFmt=num0
/>

<details>
<summary>データテーブルを表示</summary>

<DataTable data={migration_from} rows=all>
    <Column id=previous_address_name title="転入元" />
    <Column id=migrants title="転入者数" fmt=num0 />
</DataTable>

</details>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 住民基本台帳人口移動報告（総務省）</small>
