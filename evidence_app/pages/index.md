---
title: 日本の統計ダッシュボード
---

<style>
    .card-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 1rem;
        margin: 1.5rem 0;
    }
    .card {
        background: transparent;
        border: 1px solid #cbd5e1;
        border-radius: 12px;
        padding: 1.25rem 1.5rem;
        transition: border-color 0.2s;
    }
    .card:hover {
        border-color: #3b82f6;
    }
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

# 日本の統計ダッシュボード

都道府県別の統計データを可視化しています。データは e-Stat（政府統計の総合窓口）から取得しています。

## 主要指標

```sql total_pop
select
    sum(case when year_name = '2024年10月1日現在' then raw_value end) as pop_2024,
    sum(case when year_name = '2023年10月1日現在' then raw_value end) as pop_2023,
    sum(case when year_name = '2024年10月1日現在' then raw_value end)
    - sum(case when year_name = '2023年10月1日現在' then raw_value end) as pop_change
from japan_stats.mart_population
```

```sql birth_death_national
select
    sum(case when birth_death_name = '出生児数' then raw_value end) as total_births,
    sum(case when birth_death_name = '死亡者数' then raw_value end) as total_deaths,
    sum(case when birth_death_name = '出生児数' then raw_value end)
    - sum(case when birth_death_name = '死亡者数' then raw_value end) as natural_change
from japan_stats.mart_birth_death
where gender_name = '男女計'
    and nationality_name = '日本人'
```

```sql migration_national
select
    sum(raw_value) as total_migrants
from japan_stats.mart_population_migration
where nationality_code = '60000'
    and previous_address_code = '00005'
```

<div class="card-grid">
    <div class="card">
        <BigValue
            data={total_pop}
            value=pop_2024
            title="総人口（2024年）"
            fmt=num0
            comparison=pop_change
            comparisonTitle="前年比"
            comparisonFmt=num0
            downIsGood=false
            link=/japan-info-dashboard/population
        />
    </div>
    <div class="card">
        <BigValue
            data={birth_death_national}
            value=total_births
            title="出生数"
            fmt=num0
            link=/japan-info-dashboard/birth-death
        />
    </div>
    <div class="card">
        <BigValue
            data={birth_death_national}
            value=total_deaths
            title="死亡数"
            fmt=num0
            link=/japan-info-dashboard/birth-death
        />
    </div>
    <div class="card">
        <BigValue
            data={birth_death_national}
            value=natural_change
            title="自然増減"
            fmt=num0
            link=/japan-info-dashboard/birth-death
        />
    </div>
    <div class="card">
        <BigValue
            data={migration_national}
            value=total_migrants
            title="転入者数（2024年）"
            fmt=num0
            link=/japan-info-dashboard/population-migration
        />
    </div>
</div>

---

## 詳細ページ

<div class="nav-grid">
    <a class="nav-card" href="/japan-info-dashboard/population">
        <h4>都道府県別人口</h4>
        <p>都道府県別の総人口マップと前年比較</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/birth-death">
        <h4>出生・死亡者数</h4>
        <p>都道府県別の出生児数・死亡者数と自然増減</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/population-migration">
        <h4>転入者数</h4>
        <p>都道府県別の転入者数と移動前住所地の構成</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/durable-goods">
        <h4>耐久消費財の普及状況</h4>
        <p>都道府県別の主要耐久消費財の普及率</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/retail-sales">
        <h4>小売業態別 販売動向</h4>
        <p>コンビニ・家電・ドラッグストア・ホームセンターの月次販売額</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/immigration">
        <h4>新規入国外国人</h4>
        <p>国籍別・入国目的別の新規入国外国人数の推移</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/port-entry-exit">
        <h4>空港・港別 出入国者数</h4>
        <p>空港・港別の出入国者数の推移</p>
    </a>
</div>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a></small>
