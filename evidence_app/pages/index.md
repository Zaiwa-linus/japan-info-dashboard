---
title: 日本の統計ダッシュボード
---

<style>
    .nav-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 0.75rem;
        margin: 1rem 0;
    }
    .nav-card {
        display: block;
        background: transparent;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        padding: 1rem 1.25rem;
        text-decoration: none;
        color: inherit;
        transition: border-color 0.2s;
    }
    .nav-card:hover {
        border-color: #3b82f6;
    }
    .nav-card h4 {
        margin: 0 0 0.25rem 0;
        font-size: 0.95rem;
    }
    .nav-card p {
        margin: 0;
        font-size: 0.8rem;
        opacity: 0.7;
    }
</style>


都道府県別の統計データを可視化しています。データは e-Stat（政府統計の総合窓口）から取得しています。

## 主要指標

### 人口・人口動態

```sql total_pop
select
    sum(case when year_name = '2024年10月1日現在' then raw_value end) as pop_2024,
    sum(case when year_name = '2023年10月1日現在' then raw_value end) as pop_2023,
    sum(case when year_name = '2024年10月1日現在' then raw_value end)
    - sum(case when year_name = '2023年10月1日現在' then raw_value end) as pop_change
from japan_stats.mart_population
```

```sql pop_gender
select
    gender_name,
    sum(raw_value) as pop
from japan_stats.mart_population
where year_name = '2024年10月1日現在'
group by gender_name
```

```sql birth_death_national
select
    sum(case when birth_death_name = '出生児数' then raw_value end) as total_births,
    sum(case when birth_death_name = '死亡者数' then raw_value end) as total_deaths,
    sum(case when birth_death_name = '出生児数' then raw_value end)
    - sum(case when birth_death_name = '死亡者数' then raw_value end) as natural_change
from japan_stats.mart_birth_death
where nationality_name = '日本人'
```

```sql migration_national
select
    sum(raw_value) as total_migrants
from japan_stats.mart_population_migration
where nationality_code = '60000'
    and previous_address_code = '00005'
```

```sql migration_foreign
select
    sum(raw_value) as total_migrants
from japan_stats.mart_population_migration
where nationality_code in ('61000', '62000')
    and previous_address_code = '00005'
```

<CardGrid>
    <StatCard emoji="👥" title="総人口" value={total_pop[0].pop_2024} comparison={total_pop[0].pop_change} comparisonTitle="前年比" link="/japan-info-dashboard/01-demographics/population" />
    <StatCard emoji="👨" title="男性人口" value={pop_gender.find(r => r.gender_name === '男')?.pop} link="/japan-info-dashboard/01-demographics/population" />
    <StatCard emoji="👩" title="女性人口" value={pop_gender.find(r => r.gender_name === '女')?.pop} link="/japan-info-dashboard/01-demographics/population" />
    <StatCard emoji="👶" title="出生数" value={birth_death_national[0].total_births} link="/japan-info-dashboard/01-demographics/birth-death" />
    <StatCard emoji="⚰️" title="死亡数" value={birth_death_national[0].total_deaths} link="/japan-info-dashboard/01-demographics/birth-death" />
    <StatCard emoji="📊" title="自然増減" value={birth_death_national[0].natural_change} link="/japan-info-dashboard/01-demographics/birth-death" />
    <StatCard emoji="🚚" title="転入者数（日本人）" value={migration_national[0].total_migrants} link="/japan-info-dashboard/01-demographics/population-migration" />
    <StatCard emoji="🌏" title="転入者数（外国人）" value={migration_foreign[0].total_migrants} link="/japan-info-dashboard/01-demographics/population-migration" />
</CardGrid>

### 国際

```sql immigration_national
select
    sum(raw_value) as total_entries
from japan_stats.mart_immigration_by_purpose
where purpose_code = '100'
    and year = 2024
```

```sql port_national
select
    sum(raw_value) as total_travelers
from japan_stats.mart_port_entry_exit
where year = 2024
```

<CardGrid>
    <StatCard emoji="✈️" title="新規入国外国人（2024年）" value={immigration_national[0].total_entries} link="/japan-info-dashboard/02-international/immigration" />
    <StatCard emoji="🛫" title="出入国者数（2024年）" value={port_national[0].total_travelers} link="/japan-info-dashboard/02-international/port-entry-exit" />
</CardGrid>

### 経済

```sql retail_latest
select
    cast(year_month as varchar) as latest_year_month,
    period_raw_name as latest_period_name
from japan_stats.mart_retail_sales
where sales_amount is not null
order by year_month desc
limit 1
```

```sql retail_national
select
    sum(sales_amount) as total_sales
from japan_stats.mart_retail_sales
where cast(year_month as varchar) = '${retail_latest[0].latest_year_month}'
    and sales_amount is not null
```

```sql retail_by_store
select
    store_type_name,
    sum(sales_amount) as sales
from japan_stats.mart_retail_sales
where cast(year_month as varchar) = '${retail_latest[0].latest_year_month}'
    and sales_amount is not null
group by store_type_name
order by sales desc
```

<CardGrid>
    <StatCard emoji="🏪" title="小売販売額合計・${retail_latest[0].latest_period_name}" value={retail_national[0].total_sales} fmt="num0" link="/japan-info-dashboard/03-economy/retail-sales" />
    {#each retail_by_store as row}
    <StatCard emoji={row.store_type_name === 'コンビニ' ? '🏬' : row.store_type_name === 'ドラッグストア' ? '💊' : row.store_type_name === '家電大型専門店' ? '📺' : '🔨'} title="{row.store_type_name}" value={row.sales} fmt="num0" link="/japan-info-dashboard/03-economy/retail-sales" />
    {/each}
</CardGrid>

### 自然環境

```sql land_national
select
    sum(total_area_excl_northern_ha) as total_area_ha,
    sum(habitable_area_ha) as habitable_area_ha,
    sum(forest_area_ha) as total_forest_ha,
    sum(natural_park_area_ha) as total_park_ha
from japan_stats.mart_natural_environment
where area_code != '00000'
    and survey_year = (
        select max(survey_year) from japan_stats.mart_natural_environment
        where total_area_excl_northern_ha is not null
    )
```

```sql pop_density
select
    round(
        cast(${total_pop[0].pop_2024} as double)
        / (${land_national[0].total_area_ha} / 100.0),
        1
    ) as density
```

```sql climate_national
select
    round(avg(value), 1) as avg_temp
from japan_stats.mart_climate
where indicator_code = 'B4101'
    and survey_year = (
        select max(survey_year) from japan_stats.mart_climate
        where indicator_code = 'B4101'
    )
```

```sql climate_max_temp
select
    round(max(value), 1) as max_temp
from japan_stats.mart_climate
where indicator_code = 'B4102'
    and survey_year = (
        select max(survey_year) from japan_stats.mart_climate
        where indicator_code = 'B4102'
    )
```

```sql climate_min_temp
select
    round(min(value), 1) as min_temp
from japan_stats.mart_climate
where indicator_code = 'B4103'
    and survey_year = (
        select max(survey_year) from japan_stats.mart_climate
        where indicator_code = 'B4103'
    )
```

```sql climate_precip
select
    round(avg(value), 0) as avg_precip
from japan_stats.mart_climate
where indicator_code = 'B4109'
    and survey_year = (
        select max(survey_year) from japan_stats.mart_climate
        where indicator_code = 'B4109'
    )
```

```sql climate_sunshine
select
    round(avg(value), 0) as avg_sunshine
from japan_stats.mart_climate
where indicator_code = 'B4108'
    and survey_year = (
        select max(survey_year) from japan_stats.mart_climate
        where indicator_code = 'B4108'
    )
```

<CardGrid>
    <StatCard emoji="🗾" title="国土面積（ha）" value={land_national[0].total_area_ha} fmt="num0" link="/japan-info-dashboard/04-environment/land" />
    <StatCard emoji="🏘️" title="可住地面積（ha）" value={land_national[0].habitable_area_ha} fmt="num0" link="/japan-info-dashboard/04-environment/land" />
    <StatCard emoji="🌲" title="森林面積（ha）" value={land_national[0].total_forest_ha} fmt="num0" link="/japan-info-dashboard/04-environment/land" />
    <StatCard emoji="🏞️" title="自然公園面積（ha）" value={land_national[0].total_park_ha} fmt="num0" link="/japan-info-dashboard/04-environment/parks" />
    <StatCard emoji="📏" title="人口密度（人/km²）" value={pop_density[0].density} fmt="num1" link="/japan-info-dashboard/01-demographics/population" />
    <StatCard emoji="🌡️" title="平均気温（全国平均・℃）" value={climate_national[0].avg_temp} fmt="num1" link="/japan-info-dashboard/04-environment/climate" />
    <StatCard emoji="🔥" title="最高気温（全国MAX・℃）" value={climate_max_temp[0].max_temp} fmt="num1" link="/japan-info-dashboard/04-environment/climate" />
    <StatCard emoji="🧊" title="最低気温（全国MIN・℃）" value={climate_min_temp[0].min_temp} fmt="num1" link="/japan-info-dashboard/04-environment/climate" />
    <StatCard emoji="🌧️" title="年間降水量（全国平均・mm）" value={climate_precip[0].avg_precip} fmt="num0" link="/japan-info-dashboard/04-environment/climate" />
    <StatCard emoji="☀️" title="日照時間（全国平均・h）" value={climate_sunshine[0].avg_sunshine} fmt="num0" link="/japan-info-dashboard/04-environment/climate" />
</CardGrid>

---

## 詳細ページ

<a class="nav-card" href="/japan-info-dashboard/prefecture-profile">
    <h4>📋 都道府県プロフィール</h4>
    <p>都道府県を選んで人口・自然環境・経済の全体像を一覧</p>
</a>

### 人口・人口動態

<div class="nav-grid">
    <a class="nav-card" href="/japan-info-dashboard/01-demographics/population">
        <h4>都道府県別人口</h4>
        <p>都道府県別の総人口マップと前年比較</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/01-demographics/birth-death">
        <h4>出生・死亡者数</h4>
        <p>都道府県別の出生児数・死亡者数と自然増減</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/01-demographics/population-migration">
        <h4>転入者数</h4>
        <p>都道府県別の転入者数と移動前住所地の構成</p>
    </a>
</div>

### 国際

<div class="nav-grid">
    <a class="nav-card" href="/japan-info-dashboard/02-international/immigration">
        <h4>新規入国外国人</h4>
        <p>国籍別・入国目的別の新規入国外国人数の推移</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/02-international/port-entry-exit">
        <h4>空港・港別 出入国者数</h4>
        <p>空港・港別の出入国者数の推移</p>
    </a>
</div>

### 経済

<div class="nav-grid">
    <a class="nav-card" href="/japan-info-dashboard/03-economy/retail-sales">
        <h4>小売業態別 販売動向</h4>
        <p>コンビニ・家電・ドラッグストア・ホームセンターの月次販売額</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/03-economy/consumer-price-index">
        <h4>消費者物価地域差指数</h4>
        <p>都道府県別の10大費目＋総合の消費者物価指数</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/03-economy/gdp-income">
        <h4>県内総生産・県民所得</h4>
        <p>都道府県別GDP（産業別）と県民所得の推移</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/03-economy/tax">
        <h4>課税対象所得・納税義務者数</h4>
        <p>都道府県別の課税対象所得と納税義務者数の長期推移</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/03-economy/savings-debt">
        <h4>貯蓄・負債（二人以上世帯）</h4>
        <p>県庁所在市別の年間収入・貯蓄・負債の推移</p>
    </a>
</div>

### 安全

<div class="nav-grid">
    <a class="nav-card" href="/japan-info-dashboard/05-safety/crime">
        <h4>犯罪統計</h4>
        <p>都道府県別の認知件数・検挙件数・検挙率の推移</p>
    </a>
</div>

### 自然環境

<div class="nav-grid">
    <a class="nav-card" href="/japan-info-dashboard/04-environment/climate">
        <h4>気候</h4>
        <p>都道府県の気候指標（気温・降水量・日照時間等）の推移と全国比較</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/04-environment/land">
        <h4>土地</h4>
        <p>都道府県別の総面積・可住地面積・森林面積などの比較</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/04-environment/parks">
        <h4>公園</h4>
        <p>都道府県別の自然公園・国立公園・国定公園の面積と数</p>
    </a>
</div>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a></small>
