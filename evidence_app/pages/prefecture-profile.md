---
title: 都道府県プロフィール
---

<style>
    .card-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
        gap: 1rem;
        margin: 1rem 0;
    }
    .card {
        background: transparent;
        border: 1px solid #cbd5e1;
        border-radius: 12px;
        padding: 1.25rem 1.5rem;
    }
</style>

# 都道府県プロフィール

都道府県を選択すると、人口・自然環境・経済の主要データを一覧できます。

```sql prefectures
select distinct area_name
from japan_stats.mart_population
order by area_name
```

<Dropdown data={prefectures} name=selected_pref value=area_name defaultValue="東京都" />

---

## 基本情報

```sql pop_data
select
    sum(raw_value) as total_population
from japan_stats.mart_population
where area_name = '${inputs.selected_pref.value}'
    and year_name = '2024年10月1日現在'
```

```sql birth_death_data
select
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end) as birth_count,
    sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as death_count,
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end)
    - sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as natural_change
from japan_stats.mart_birth_death
where area_name = '${inputs.selected_pref.value}'
    and gender_name = '男女計'
    and nationality_name = '日本人'
```

```sql migration_data
select
    raw_value as total_migrants
from japan_stats.mart_population_migration
where current_address_name = '${inputs.selected_pref.value}'
    and nationality_code = '60000'
    and previous_address_code = '00005'
```

<div class="card-grid">
    <div class="card">
        <BigValue data={pop_data} value=total_population title="総人口（2024年）" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={birth_death_data} value=birth_count title="出生数" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={birth_death_data} value=death_count title="死亡数" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={birth_death_data} value=natural_change title="自然増減" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={migration_data} value=total_migrants title="転入者数" fmt=num0 />
    </div>
</div>

---

## 自然環境

```sql env_data
select *
from japan_stats.mart_natural_environment
where area_name = '${inputs.selected_pref.value}'
order by year desc
limit 1
```

### 土地

<div class="card-grid">
    <div class="card">
        <BigValue data={env_data} value=total_area_excl_northern_ha title="総面積（ha）" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={env_data} value=habitable_area_ha title="可住地面積（ha）" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={env_data} value=forest_area_ha title="森林面積（ha）" fmt=num0 />
    </div>
</div>

### 気候

<div class="card-grid">
    <div class="card">
        <BigValue data={env_data} value=avg_temperature_celsius title="年平均気温（℃）" fmt=num1 />
    </div>
    <div class="card">
        <BigValue data={env_data} value=precipitation_mm title="年間降水量（mm）" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={env_data} value=sunshine_hours title="日照時間（h）" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={env_data} value=max_snow_depth_cm title="最深積雪（cm）" fmt=num0 />
    </div>
</div>

### 公園

<div class="card-grid">
    <div class="card">
        <BigValue data={env_data} value=natural_park_area_ha title="自然公園面積（ha）" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={env_data} value=prefectural_park_count title="都道府県立公園数" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={env_data} value=national_park_area_ha title="国立公園面積（ha）" fmt=num0 />
    </div>
    <div class="card">
        <BigValue data={env_data} value=quasi_national_park_area_ha title="国定公園面積（ha）" fmt=num0 />
    </div>
</div>

### 植生自然度

```sql vegetation_all
with latest as (
    select *
    from japan_stats.mart_natural_environment
    where area_name = '${inputs.selected_pref.value}'
        and vegetation_naturalness_1_pct is not null
    order by year desc
    limit 1
)
select unnest.category, unnest.value
from latest,
lateral (values
    ('1: 市街地等', vegetation_naturalness_1_pct),
    ('2: 農耕地（水田・畑）', vegetation_naturalness_2_pct),
    ('3: 農耕地（樹園地）', vegetation_naturalness_3_pct),
    ('4: 二次草原（低）', vegetation_naturalness_4_pct),
    ('5: 二次草原（高）', vegetation_naturalness_5_pct),
    ('6: 植林地', vegetation_naturalness_6_pct),
    ('7: 二次林（落葉広葉樹）', vegetation_naturalness_7_pct),
    ('8: 二次林（常緑針葉樹）', vegetation_naturalness_8_pct),
    ('9: 自然林', vegetation_naturalness_9_pct),
    ('10: 自然植生', vegetation_naturalness_10_pct)
) as unnest(category, value)
```

<BarChart
    data={vegetation_all}
    x=category
    y=value
    title="{inputs.selected_pref.value} の植生自然度構成（%）"
    yAxisTitle="%"
    xAxisTitle="自然度"
    sort=false
    yFmt=num1
/>

---

## 人口動態

### 出生・死亡（性別内訳）

```sql birth_death_gender
select
    gender_name,
    sum(case when birth_death_name = '出生児数' then raw_value else 0 end) as birth_count,
    sum(case when birth_death_name = '死亡者数' then raw_value else 0 end) as death_count
from japan_stats.mart_birth_death
where area_name = '${inputs.selected_pref.value}'
    and nationality_name = '日本人'
    and gender_name != '男女計'
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

```sql retail_trend
select
    year_month,
    store_type_name,
    sales_amount
from japan_stats.mart_retail_sales
where area_name = '${inputs.selected_pref.value}'
    and sales_amount is not null
order by year_month
```

<LineChart
    data={retail_trend}
    x=year_month
    y=sales_amount
    series=store_type_name
    title="{inputs.selected_pref.value} の小売販売額 月次推移"
    yAxisTitle="販売額（百万円）"
    yFmt=num0
/>

### 耐久消費財（全国平均との比較）

```sql durable_comparison
select
    d.indicator_short_name,
    d.raw_value as pref_value,
    n.raw_value as national_value
from japan_stats.mart_durable_goods d
left join (
    select indicator_code, raw_value
    from japan_stats.mart_durable_goods
    where area_name = '全国'
    order by year desc
    limit 100
) n on d.indicator_code = n.indicator_code
where d.area_name = '${inputs.selected_pref.value}'
    and d.raw_value is not null
order by d.year desc, d.indicator_short_name
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

<BarChart
    data={durable_latest}
    x=indicator_short_name
    y={["pref_value", "national_value"]}
    seriesNames={["{inputs.selected_pref.value}", "全国平均"]}
    title="耐久消費財 普及率（千世帯あたり・最新年）"
    yAxisTitle="千世帯あたり所有数量"
    type=grouped
    yFmt=num0
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a></small>
<small>地図データ出典：<a href="https://www.gsi.go.jp/kankyochiri/gm_japan_e.html" target="_blank">地球地図日本</a>（国土地理院）</small>
