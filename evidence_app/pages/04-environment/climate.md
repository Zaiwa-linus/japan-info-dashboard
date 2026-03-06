---
title: 気候
sidebar_position: 1
---

都道府県の気候データを指標別に比較・分析できます。

```sql indicators
select distinct
    indicator_code,
    indicator_label || '（' || unit || '）' as indicator_display
from japan_stats.mart_climate
order by indicator_code
```

<Dropdown data={indicators} name=selected_indicator value=indicator_code label=indicator_display defaultValue="B4101" />

---

```sql selected_info
select distinct indicator_label, unit
from japan_stats.mart_climate
where indicator_code = '${inputs.selected_indicator.value}'
```

```sql map_survey_year
select max(survey_year) as latest_survey_year
from japan_stats.mart_climate
where indicator_code = '${inputs.selected_indicator.value}'
```

```sql ranking
select area_code, area_name, value
from japan_stats.mart_climate
where indicator_code = '${inputs.selected_indicator.value}'
    and survey_year = ${map_survey_year[0].latest_survey_year}
order by value desc
```

```sql top3
select * from ${ranking} limit 3
```

```sql bottom3
select * from ${ranking} order by value asc limit 3
```

#### {selected_info[0].indicator_label} Top 3

<CardGrid>
    {#each top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.area_name}" value={row.value} />
    {/each}
</CardGrid>

#### {selected_info[0].indicator_label} Bottom 3

<CardGrid>
    {#each bottom3 as row, i}
    <StatCard emoji={["1️⃣", "2️⃣", "3️⃣"][i]} title="{row.area_name}" value={row.value} />
    {/each}
</CardGrid>

---

## 全国マップ

<small>※ {map_survey_year[0].latest_survey_year}年データ</small>

<TileMap data={ranking} fmt="num1" />

---

## 都道府県別の推移

```sql prefectures
select distinct area_name, area_code
from japan_stats.mart_climate
order by area_code
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都" />

```sql trend_data
select make_date(cast(survey_year as integer), 1, 1) as survey_year_date, value
from japan_stats.mart_climate
where area_name = '${inputs.selected_pref.value}'
    and indicator_code = '${inputs.selected_indicator.value}'
order by survey_year_date
```

<LineChart
    data={trend_data}
    x=survey_year_date
    xFmt=yyyy
    y=value
    yAxisTitle="{selected_info[0].indicator_label}（{selected_info[0].unit}）"
    yFmt=num1
/>

<details>
<summary>データテーブルを表示</summary>

<DataTable data={ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=value title="{selected_info[0].indicator_label}（{selected_info[0].unit}）" fmt=num1 />
</DataTable>

</details>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a></small>
