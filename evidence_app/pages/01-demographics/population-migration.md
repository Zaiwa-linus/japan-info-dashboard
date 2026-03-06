---
title: 都道府県別 転入者数
sidebar_position: 4
---


住民基本台帳人口移動報告（総務省）のデータを基に、都道府県別の転入者数を可視化しています。2024年のデータを収録しています。

---

## 都道府県別 転入者数ランキング

```sql total_migration
select
    current_address_name,
    current_address_code,
    raw_value as total_migrants
from japan_stats.mart_population_migration
where nationality_code = '60000'
    and previous_address_code = '00005'
order by raw_value desc
```

<BarChart
    data={total_migration}
    x=current_address_name
    y=total_migrants
    title="都道府県別 転入者数（2024年・移動者全体）"
    yAxisTitle="転入者数（人）"
    swapXY=true
    sort=false
    yFmt=num0
/>

<DataTable data={total_migration} rows=all search=true>
    <Column id=current_address_name title="都道府県" />
    <Column id=total_migrants title="転入者数" fmt=num0 />
</DataTable>

---

## 転入者数マップ

<TileMap data={total_migration} areaCodeCol="current_address_code" areaNameCol="current_address_name" valueCol="total_migrants" fmt="num0" />

---

## 外国人の転入先ランキング

```sql foreign_migration
select
    current_address_name,
    current_address_code,
    raw_value as foreign_migrants
from japan_stats.mart_population_migration
where nationality_code = '62000'
    and previous_address_code = '00005'
order by raw_value desc
```

<BarChart
    data={foreign_migration}
    x=current_address_name
    y=foreign_migrants
    title="都道府県別 外国人転入者数（2024年）"
    yAxisTitle="転入者数（人）"
    swapXY=true
    sort=false
    yFmt=num0
/>

<TileMap data={foreign_migration} areaCodeCol="current_address_code" areaNameCol="current_address_name" valueCol="foreign_migrants" fmt="num0" />

---

## 移動前の住所地別 構成（どこから来たか）

```sql prefectures
select distinct current_address_name
from japan_stats.mart_population_migration
where previous_address_code = '00005'
    and nationality_code = '60000'
order by current_address_name
```

<Dropdown data={prefectures} name=selected_pref value=current_address_name defaultValue="東京都" />

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

<DataTable data={migration_from} rows=all>
    <Column id=previous_address_name title="転入元" />
    <Column id=migrants title="転入者数" fmt=num0 />
</DataTable>

---

## 日本人 vs 外国人 転入者数比較

```sql nationality_comparison
select
    current_address_name,
    current_address_code,
    nationality_name,
    raw_value as migrants
from japan_stats.mart_population_migration
where previous_address_code = '00005'
    and nationality_code in ('61000', '62000')
order by current_address_code, nationality_code
```

```sql nationality_top15
select
    current_address_name,
    nationality_name,
    migrants
from (
    select
        current_address_name,
        current_address_code,
        nationality_name,
        raw_value as migrants,
        row_number() over (partition by nationality_code order by raw_value desc) as rn
    from japan_stats.mart_population_migration
    where previous_address_code = '00005'
        and nationality_code in ('61000', '62000')
) sub
where rn <= 15
order by current_address_code
```

<BarChart
    data={nationality_top15}
    x=current_address_name
    y=migrants
    series=nationality_name
    title="都道府県別 転入者数 Top 15（日本人 vs 外国人）"
    yAxisTitle="転入者数（人）"
    type=grouped
    swapXY=true
    yFmt=num0
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 住民基本台帳人口移動報告（総務省）</small>
