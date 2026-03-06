---
title: 都道府県プロフィール
sidebar_position: 1
---

都道府県を選択すると、人口・自然環境・経済の主要データを一覧できます。

```sql prefectures
select distinct area_name, area_code
from japan_stats.mart_population
order by area_code
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都" />

---

```sql pop_latest_year
select max(year_name) as latest_year
from japan_stats.mart_population
where area_name = '${inputs.selected_pref.value}'
```

```sql pop_data
select
    sum(raw_value) as total_population
from japan_stats.mart_population
where area_name = '${inputs.selected_pref.value}'
    and year_name = '${pop_latest_year[0].latest_year}'
```

```sql birth_death_data
select
    max(year_name) as latest_year,
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end) as birth_count,
    sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as death_count,
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end)
    - sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as natural_change
from japan_stats.mart_birth_death
where area_name = '${inputs.selected_pref.value}'
    and nationality_name = '日本人'
```

```sql migration_data
select
    year_name as latest_year,
    raw_value as total_migrants
from japan_stats.mart_population_migration
where current_address_name = '${inputs.selected_pref.value}'
    and nationality_code = '60000'
    and previous_address_code = '00005'
```

## 基本情報

<small>※ 人口: {pop_latest_year[0].latest_year} ／ 出生・死亡: {birth_death_data[0].latest_year} ／ 転入: {migration_data[0].latest_year}</small>

<CardGrid>
    <StatCard emoji="👥" title="総人口" value={pop_data[0].total_population} />
    <StatCard emoji="👶" title="出生数" value={birth_death_data[0].birth_count} />
    <StatCard emoji="⚰️" title="死亡数" value={birth_death_data[0].death_count} />
    <StatCard emoji="📊" title="自然増減" value={birth_death_data[0].natural_change} />
    <StatCard emoji="🚚" title="転入者数" value={migration_data[0].total_migrants} />
</CardGrid>

---

```sql env_data
select *, survey_year as env_year
from japan_stats.mart_natural_environment
where area_name = '${inputs.selected_pref.value}'
order by survey_year desc
limit 1
```

## 自然環境

<small>※ {env_data[0].env_year}年度データ</small>

### 🗾 土地

<CardGrid>
    <StatCard emoji="🗾" title="総面積（ha）" value={env_data[0].total_area_incl_northern_ha} />
    <StatCard emoji="🏘️" title="可住地面積（ha）" value={env_data[0].habitable_area_ha} />
    <StatCard emoji="🌊" title="主要湖沼面積（ha）" value={env_data[0].major_lake_area_ha} />
    <StatCard emoji="🛡️" title="自然保護地区面積（ha）" value={env_data[0].nature_conservation_area_ha} />
</CardGrid>

### 🌤️ 気候

<CardGrid>
    <StatCard emoji="🌡️" title="平均気温（℃）" value={env_data[0].avg_temperature_celsius} fmt="num1" />
    <StatCard emoji="🔥" title="最高気温（℃）" value={env_data[0].max_temperature_celsius} fmt="num1" />
    <StatCard emoji="🧊" title="最低気温（℃）" value={env_data[0].min_temperature_celsius} fmt="num1" />
    <StatCard emoji="☀️" title="日照時間（h）" value={env_data[0].sunshine_hours} />
    <StatCard emoji="🌧️" title="年間降水量（mm）" value={env_data[0].precipitation_mm} />
    <StatCard emoji="🌧️" title="雨天日数" value={env_data[0].rainy_days} />
    <StatCard emoji="💧" title="平均湿度（%）" value={env_data[0].avg_relative_humidity_pct} fmt="num1" />
</CardGrid>

### 🏞️ 公園

<CardGrid>
    <StatCard emoji="🏞️" title="自然公園面積（ha）" value={env_data[0].natural_park_area_ha} />
    <StatCard emoji="🏛️" title="都道府県立公園数" value={env_data[0].prefectural_park_count} />
    <StatCard emoji="🏛️" title="都道府県立公園面積（ha）" value={env_data[0].prefectural_park_area_ha} />
    <StatCard emoji="⛰️" title="国立公園面積（ha）" value={env_data[0].national_park_area_ha} />
    <StatCard emoji="🏔️" title="国定公園面積（ha）" value={env_data[0].quasi_national_park_area_ha} />
</CardGrid>

---

## 人口動態

<small>※ 出生・死亡: {birth_death_data[0].latest_year} ／ 転入: {migration_data[0].latest_year}</small>

### 出生・死亡（性別内訳）

```sql birth_death_gender
select
    gender_name,
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end) as birth_count,
    sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as death_count
from japan_stats.mart_birth_death
where area_name = '${inputs.selected_pref.value}'
    and nationality_name = '日本人'
group by gender_name
order by gender_name
```

<BarChart
    data={birth_death_gender}
    x=gender_name
    y={["birth_count", "death_count"]}
    seriesNames={["出生児数", "死亡者数"]}
    title="{inputs.selected_pref.value} の出生児数・死亡者数（性別）"
    yAxisTitle="人数（人）"
    type=grouped
    swapXY=true
    yFmt=num0
/>

### 転入元 Top 10

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
limit 10
```

<BarChart
    data={migration_from}
    x=previous_address_name
    y=migrants
    title="{inputs.selected_pref.value}への転入元 Top 10"
    yAxisTitle="転入者数（人）"
    swapXY=true
    sort=false
    yFmt=num0
/>

---

## 経済

### 小売販売 月次推移（業態別）

```sql retail_period
select
    min(year_month) as min_ym,
    max(year_month) as max_ym
from japan_stats.mart_retail_sales
where area_name = '${inputs.selected_pref.value}'
    and sales_amount is not null
```

```sql retail_trend
select
    year_month,
    store_type_name,
    sales_amount,
    store_count
from japan_stats.mart_retail_sales
where area_name = '${inputs.selected_pref.value}'
    and sales_amount is not null
order by year_month
```

<small>※ {retail_period[0].min_ym} ～ {retail_period[0].max_ym}</small>

<LineChart
    data={retail_trend}
    x=year_month
    y=sales_amount
    series=store_type_name
    title="{inputs.selected_pref.value} の小売販売額 月次推移"
    yAxisTitle="販売額（百万円）"
    yFmt=num0
/>

<LineChart
    data={retail_trend}
    x=year_month
    y=store_count
    series=store_type_name
    title="{inputs.selected_pref.value} の店舗数 月次推移"
    yAxisTitle="店舗数"
    yFmt=num0
/>

### 耐久消費財（全国平均との比較）

```sql durable_latest_year
select max(d.year) as latest_year
from japan_stats.mart_durable_goods d
where d.area_name = '${inputs.selected_pref.value}'
    and d.raw_value is not null
```

```sql durable_latest
select
    d.indicator_short_name,
    d.raw_value as pref_value,
    n.national_value
from (
    select indicator_code, indicator_short_name, raw_value, year,
        row_number() over (partition by indicator_code order by year desc) as rn
    from japan_stats.mart_durable_goods
    where area_name = '${inputs.selected_pref.value}'
        and raw_value is not null
) d
left join (
    select indicator_code,
        raw_value as national_value,
        row_number() over (partition by indicator_code order by year desc) as rn
    from japan_stats.mart_durable_goods
    where area_name = '全国'
        and raw_value is not null
) n on d.indicator_code = n.indicator_code and n.rn = 1
where d.rn = 1
order by d.indicator_short_name
```

<small>※ {durable_latest_year[0].latest_year}年データ</small>

<BarChart
    data={durable_latest}
    x=indicator_short_name
    y={["pref_value", "national_value"]}
    seriesNames={["{inputs.selected_pref.value}", "全国平均"]}
    title="耐久消費財 普及率（千世帯あたり）"
    yAxisTitle="千世帯あたり所有数量"
    type=grouped
    swapXY=true
    yFmt=num0
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a></small>
<small>地図データ出典：<a href="https://www.gsi.go.jp/kankyochiri/gm_japan_e.html" target="_blank">地球地図日本</a>（国土地理院）</small>
