---
title: 都道府県別 出生・死亡者数
sidebar_position: 3
---

人口推計（総務省）のデータを基に、都道府県別の出生児数・自然増減を可視化しています。2023年10月〜2024年9月の年間データを収録しています。

---

## 出生児数

```sql birth_ranking
select
    area_name,
    area_code,
    sum(raw_value) as birth_count
from japan_stats.mart_birth_death
where nationality_name = '日本人'
    and birth_death_name = '出生児数'
group by area_name, area_code
order by birth_count desc
```

```sql birth_top3
select * from ${birth_ranking} limit 3
```

```sql birth_bottom3
select * from ${birth_ranking} order by birth_count asc limit 3
```

#### 出生児数 Top 3

<CardGrid>
    {#each birth_top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.area_name}" value={row.birth_count} />
    {/each}
</CardGrid>

#### 出生児数 Bottom 3

<CardGrid>
    {#each birth_bottom3 as row, i}
    <StatCard emoji={["1️⃣", "2️⃣", "3️⃣"][i]} title="{row.area_name}" value={row.birth_count} />
    {/each}
</CardGrid>

### 出生児数マップ

<TileMap data={birth_ranking} valueCol="birth_count" fmt="num0" />

<details>
<summary>データテーブルを表示</summary>

<DataTable data={birth_ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=birth_count title="出生児数" fmt=num0 />
</DataTable>

</details>

---

## 自然増減（出生 - 死亡）

```sql natural_change_ranking
select
    area_name,
    area_code,
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end)
    - sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as natural_change
from japan_stats.mart_birth_death
where nationality_name = '日本人'
group by area_name, area_code
order by natural_change desc
```

```sql nc_top3
select * from ${natural_change_ranking} limit 3
```

```sql nc_bottom3
select * from ${natural_change_ranking} order by natural_change asc limit 3
```

#### 自然減が少ない Top 3

<CardGrid>
    {#each nc_top3 as row, i}
    <StatCard emoji={["🥇", "🥈", "🥉"][i]} title="{row.area_name}" value={row.natural_change} />
    {/each}
</CardGrid>

#### 自然減が大きい Bottom 3

<CardGrid>
    {#each nc_bottom3 as row, i}
    <StatCard emoji={["1️⃣", "2️⃣", "3️⃣"][i]} title="{row.area_name}" value={row.natural_change} />
    {/each}
</CardGrid>

### 自然増減マップ

<DivergingTileMap data={natural_change_ranking} valueCol="natural_change" fmt="num0" />

<details>
<summary>データテーブルを表示</summary>

<DataTable data={natural_change_ranking} rows=all search=true>
    <Column id=area_name title="都道府県" />
    <Column id=natural_change title="自然増減" fmt=num0 />
</DataTable>

</details>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 人口推計（総務省）</small>
