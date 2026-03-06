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

## 主要指標（2024年）

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
where nationality_name = '日本人'
```

```sql migration_national
select
    sum(raw_value) as total_migrants
from japan_stats.mart_population_migration
where nationality_code = '60000'
    and previous_address_code = '00005'
```

<CardGrid>
    <StatCard emoji="👥" title="総人口" value={total_pop[0].pop_2024} comparison={total_pop[0].pop_change} comparisonTitle="前年比" link="/japan-info-dashboard/01-demographics/population" />
    <StatCard emoji="👶" title="出生数" value={birth_death_national[0].total_births} link="/japan-info-dashboard/01-demographics/birth-death" />
    <StatCard emoji="⚰️" title="死亡数" value={birth_death_national[0].total_deaths} link="/japan-info-dashboard/01-demographics/birth-death" />
    <StatCard emoji="📊" title="自然増減" value={birth_death_national[0].natural_change} link="/japan-info-dashboard/01-demographics/birth-death" />
    <StatCard emoji="🚚" title="転入者数" value={migration_national[0].total_migrants} link="/japan-info-dashboard/01-demographics/population-migration" />
</CardGrid>

---

## 詳細ページ

<div class="nav-grid">
    <a class="nav-card" href="/japan-info-dashboard/prefecture-profile">
        <h4>都道府県プロフィール</h4>
        <p>都道府県を選んで人口・自然環境・経済の全体像を一覧</p>
    </a>
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
    <a class="nav-card" href="/japan-info-dashboard/03-economy/durable-goods">
        <h4>耐久消費財の普及状況</h4>
        <p>都道府県別の主要耐久消費財の普及率</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/03-economy/retail-sales">
        <h4>小売業態別 販売動向</h4>
        <p>コンビニ・家電・ドラッグストア・ホームセンターの月次販売額</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/04-environment/climate">
        <h4>気候</h4>
        <p>都道府県の気候指標（気温・降水量・日照時間等）の推移と全国比較</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/02-international/immigration">
        <h4>新規入国外国人</h4>
        <p>国籍別・入国目的別の新規入国外国人数の推移</p>
    </a>
    <a class="nav-card" href="/japan-info-dashboard/02-international/port-entry-exit">
        <h4>空港・港別 出入国者数</h4>
        <p>空港・港別の出入国者数の推移</p>
    </a>
</div>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a></small>
