---
title: 都道府県別 出生・死亡者数
sidebar_position: 3
---

# 都道府県別 出生・死亡者数

人口推計（総務省）のデータを基に、都道府県別の出生児数・死亡者数を可視化しています。2023年10月〜2024年9月の年間データを収録しています。

---

## 都道府県別 出生数・死亡数（対比）

```sql birth_death_total
select
    area_name,
    area_code,
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end) as birth_count,
    sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as death_count,
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end)
    - sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as natural_change
from japan_stats.mart_birth_death
where gender_name = '男女計'
    and nationality_name = '日本人'
group by area_name, area_code
order by area_code
```

<BarChart
    data={birth_death_total}
    x=area_name
    y={["birth_count", "death_count"]}
    seriesNames={["出生児数", "死亡者数"]}
    title="都道府県別 出生児数・死亡者数（日本人・男女計）"
    yAxisTitle="人数（人）"
    type=grouped
    yFmt=num0
/>

---

## 自然増減（出生 - 死亡）ランキング

```sql natural_change_ranking
select
    area_name,
    area_code,
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end) as birth_count,
    sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as death_count,
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end)
    - sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as natural_change
from japan_stats.mart_birth_death
where gender_name = '男女計'
    and nationality_name = '日本人'
group by area_name, area_code
order by natural_change desc
```

<BarChart
    data={natural_change_ranking}
    x=area_name
    y=natural_change
    title="都道府県別 自然増減（出生 - 死亡）"
    yAxisTitle="自然増減（人）"
    sort=false
    yFmt=num0
/>

全都道府県で死亡者数が出生児数を上回り、自然減となっています。沖縄県が最も自然減が少なく、東京都が最も自然減が大きい状況です。

<DataTable data={natural_change_ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=birth_count title="出生児数" fmt=num0 />
    <Column id=death_count title="死亡者数" fmt=num0 />
    <Column id=natural_change title="自然増減" fmt=num0 />
</DataTable>

---

## 自然増減マップ

<AreaMap
    data={natural_change_ranking}
    geoJsonUrl=/japan-info-dashboard/japan_prefectures.geojson
    geoId=nam_ja
    areaCol=area_name
    value=natural_change
    valueFmt=num0
    title="都道府県別 自然増減（出生 - 死亡）"
    height=500
    legendType=scalar
    tooltip={[{id: 'area_name', title: '都道府県'}, {id: 'birth_count', title: '出生児数', fmt: 'num0'}, {id: 'death_count', title: '死亡者数', fmt: 'num0'}, {id: 'natural_change', title: '自然増減', fmt: 'num0'}]}
/>

---

## 日本人 vs 外国人の比較

```sql by_nationality
select
    nationality_name,
    birth_death_name,
    sum(raw_value) as total_count
from japan_stats.mart_birth_death
where gender_name = '男女計'
group by nationality_name, birth_death_name
order by nationality_name, birth_death_name
```

<BarChart
    data={by_nationality}
    x=nationality_name
    y=total_count
    series=birth_death_name
    title="日本人 vs 外国人 出生児数・死亡者数（全国計）"
    yAxisTitle="人数（人）"
    type=grouped
    yFmt=num0
/>

---

## 男女別 出生児数・死亡者数

```sql by_gender
select
    area_name,
    area_code,
    gender_name,
    birth_death_name,
    raw_value
from japan_stats.mart_birth_death
where gender_name != '男女計'
    and nationality_name = '日本人'
order by area_code, gender_name, birth_death_name
```

```sql gender_summary
select
    gender_name,
    birth_death_name,
    sum(raw_value) as total_count
from japan_stats.mart_birth_death
where gender_name != '男女計'
    and nationality_name = '日本人'
group by gender_name, birth_death_name
order by gender_name, birth_death_name
```

<BarChart
    data={gender_summary}
    x=gender_name
    y=total_count
    series=birth_death_name
    title="男女別 出生児数・死亡者数（日本人・全国計）"
    yAxisTitle="人数（人）"
    type=grouped
    yFmt=num0
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 人口推計（総務省）</small>
