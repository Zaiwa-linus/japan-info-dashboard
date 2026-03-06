---
title: 土地
sidebar_position: 2
---

都道府県の土地利用データを指標別に比較・分析できます。

```sql indicators
select * from (
    values
        ('total_area_excl_northern_ha', '総面積（北方地域を除く）', 'ha'),
        ('habitable_area_ha', '可住地面積', 'ha'),
        ('major_lake_area_ha', '主要湖沼面積', 'ha'),
        ('forest_and_field_area_ha', '林野面積', 'ha'),
        ('forest_area_ha', '森林面積', 'ha'),
        ('grassland_area_ha', '原野面積', 'ha'),
        ('nature_conservation_area_ha', '自然保護地域面積', 'ha'),
        ('assessed_land_total_m2', '評価総地積', 'm²'),
        ('assessed_land_paddy_m2', '地積（田）', 'm²'),
        ('assessed_land_field_m2', '地積（畑）', 'm²'),
        ('assessed_land_residential_m2', '地積（宅地）', 'm²'),
        ('assessed_land_mountain_m2', '地積（山林）', 'm²'),
        ('afforestation_area_ha', '造林面積', 'ha')
) as t(indicator_code, indicator_label, unit)
```

<Dropdown data={indicators} name=selected_indicator value=indicator_code label=indicator_label defaultValue="total_area_excl_northern_ha" />

---

```sql selected_info
select indicator_label, unit
from ${indicators}
where indicator_code = '${inputs.selected_indicator.value}'
```

```sql ranking
select area_code, area_name, survey_year,
    case '${inputs.selected_indicator.value}'
        when 'total_area_excl_northern_ha' then total_area_excl_northern_ha
        when 'habitable_area_ha' then habitable_area_ha
        when 'major_lake_area_ha' then major_lake_area_ha
        when 'forest_and_field_area_ha' then forest_and_field_area_ha
        when 'forest_area_ha' then forest_area_ha
        when 'grassland_area_ha' then grassland_area_ha
        when 'nature_conservation_area_ha' then nature_conservation_area_ha
        when 'assessed_land_total_m2' then assessed_land_total_m2
        when 'assessed_land_paddy_m2' then assessed_land_paddy_m2
        when 'assessed_land_field_m2' then assessed_land_field_m2
        when 'assessed_land_residential_m2' then assessed_land_residential_m2
        when 'assessed_land_mountain_m2' then assessed_land_mountain_m2
        when 'afforestation_area_ha' then afforestation_area_ha
    end as value
from japan_stats.mart_natural_environment
where area_code != '00000'
    and case '${inputs.selected_indicator.value}'
        when 'total_area_excl_northern_ha' then total_area_excl_northern_ha
        when 'habitable_area_ha' then habitable_area_ha
        when 'major_lake_area_ha' then major_lake_area_ha
        when 'forest_and_field_area_ha' then forest_and_field_area_ha
        when 'forest_area_ha' then forest_area_ha
        when 'grassland_area_ha' then grassland_area_ha
        when 'nature_conservation_area_ha' then nature_conservation_area_ha
        when 'assessed_land_total_m2' then assessed_land_total_m2
        when 'assessed_land_paddy_m2' then assessed_land_paddy_m2
        when 'assessed_land_field_m2' then assessed_land_field_m2
        when 'assessed_land_residential_m2' then assessed_land_residential_m2
        when 'assessed_land_mountain_m2' then assessed_land_mountain_m2
        when 'afforestation_area_ha' then afforestation_area_ha
    end is not null
```

```sql map_survey_year
select max(survey_year) as latest_survey_year
from ${ranking}
```

```sql ranking_latest
select area_code, area_name, value
from ${ranking}
where survey_year = ${map_survey_year[0].latest_survey_year}
order by value desc
```

```sql top3
select * from ${ranking_latest} limit 3
```

```sql bottom3
select * from ${ranking_latest} order by value asc limit 3
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

<TileMap data={ranking_latest} fmt="num0" />

---

## 都道府県別の推移

```sql prefectures
select distinct area_name, area_code
from japan_stats.mart_natural_environment
where area_code != '00000'
order by area_code
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都" />

```sql trend_data
select make_date(cast(survey_year as integer), 1, 1) as survey_year_date, value
from ${ranking}
where area_name = '${inputs.selected_pref.value}'
order by survey_year_date
```

<LineChart
    data={trend_data}
    x=survey_year_date
    xFmt=yyyy
    y=value
    yAxisTitle="{selected_info[0].indicator_label}（{selected_info[0].unit}）"
    yFmt=num0
/>

<details>
<summary>データテーブルを表示</summary>

<DataTable data={ranking_latest} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=value title="{selected_info[0].indicator_label}（{selected_info[0].unit}）" fmt=num0 />
</DataTable>

</details>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a></small>
