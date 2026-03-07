---
title: 国籍別・入国目的別 新規入国外国人
sidebar_position: 5
---


出入国管理統計（法務省）のデータを基に、新規入国外国人を国籍・入国目的別に可視化しています。2002年〜2024年の時系列データを収録しています。

---

## 年次推移（2002〜2024年）

```sql yearly_total
select
    year,
    sum(raw_value) as total_entries
from japan_stats.mart_immigration_by_purpose
where purpose_code = '100'
group by year
order by year
```

<LineChart
    data={yearly_total}
    x=year
    y=total_entries
    title="新規入国外国人 総数の推移（短期滞在）"
    yAxisTitle="入国者数（人）"
    xAxisTitle="年"
    yFmt=num0
/>

コロナ禍（2020〜2021年）で激減した後、2023年に大きく回復し、2024年には過去最高を記録しています。

---

## 国籍別入国者数ランキング（Top 20）

```sql years
select distinct year from japan_stats.mart_immigration_by_purpose order by year desc
```

```sql regions
select distinct region from japan_stats.mart_immigration_by_purpose where region is not null order by region
```

<Dropdown data={years} name=selected_year value=year defaultValue={years[0].year} />
<Dropdown data={regions} name=selected_region value=region>
    <DropdownOption valueLabel="すべての地域" value="%" />
</Dropdown>

```sql top_countries
select
    nationality_name,
    sum(raw_value) as total_entries
from japan_stats.mart_immigration_by_purpose
where purpose_code = '100'
    and year = ${inputs.selected_year.value}
    and region like '${inputs.selected_region.value}'
group by nationality_name
order by total_entries desc
limit 20
```

<BarChart
    data={top_countries}
    x=nationality_name
    y=total_entries
    title="国籍別 入国者数 Top 20（{inputs.selected_year.value}年・短期滞在）"
    yAxisTitle="入国者数（人）"
    swapXY=true
    sort=false
    yFmt=num0
/>

<DataTable data={top_countries} rows=all>
    <Column id=nationality_name title="国籍・地域" />
    <Column id=total_entries title="入国者数" fmt=num0 />
</DataTable>

---

## 入国目的別 構成比

```sql purpose_breakdown
select
    purpose_name,
    sum(raw_value) as total_entries
from japan_stats.mart_immigration_by_purpose
where is_subtotal = false
    and year = ${inputs.selected_year.value}
    and purpose_category = '短期滞在'
    and region like '${inputs.selected_region.value}'
group by purpose_name
order by total_entries desc
```

```sql purpose_category_breakdown
select
    purpose_category,
    sum(raw_value) as total_entries
from japan_stats.mart_immigration_by_purpose
where is_subtotal = true
    and year = ${inputs.selected_year.value}
    and region like '${inputs.selected_region.value}'
group by purpose_category
order by total_entries desc
```

### 大分類別

<ECharts config={
    {
        tooltip: {trigger: 'item', formatter: '{b}: {c}人 ({d}%)'},
        series: [{
            type: 'pie',
            radius: ['40%', '70%'],
            data: purpose_category_breakdown.map(row => ({name: row.purpose_category, value: row.total_entries})),
            label: {formatter: '{b}\n{d}%'}
        }]
    }
}/>

### 短期滞在の内訳

<ECharts config={
    {
        tooltip: {trigger: 'item', formatter: '{b}: {c}人 ({d}%)'},
        series: [{
            type: 'pie',
            radius: ['40%', '70%'],
            data: purpose_breakdown.map(row => ({name: row.purpose_name, value: row.total_entries})),
            label: {formatter: '{b}\n{d}%'}
        }]
    }
}/>

---

## 主要国の入国目的内訳

```sql major_countries_purpose
select
    nationality_name,
    purpose_name,
    sum(raw_value) as total_entries
from japan_stats.mart_immigration_by_purpose
where is_subtotal = false
    and year = ${inputs.selected_year.value}
    and purpose_category = '短期滞在'
    and region like '${inputs.selected_region.value}'
    and nationality_name in (
        select nationality_name
        from japan_stats.mart_immigration_by_purpose
        where purpose_code = '100'
            and year = ${inputs.selected_year.value}
            and region like '${inputs.selected_region.value}'
        order by raw_value desc
        limit 10
    )
group by nationality_name, purpose_name
order by nationality_name, total_entries desc
```

<BarChart
    data={major_countries_purpose}
    x=nationality_name
    y=total_entries
    series=purpose_name
    title="主要国の短期滞在 入国目的内訳（{inputs.selected_year.value}年）"
    yAxisTitle="入国者数（人）"
    type=stacked
    swapXY=true
    yFmt=num0
/>

---

## 主要国の年次推移

```sql top10_trend
select
    year,
    nationality_name,
    sum(raw_value) as total_entries
from japan_stats.mart_immigration_by_purpose
where purpose_code = '100'
    and nationality_name in (
        select nationality_name
        from japan_stats.mart_immigration_by_purpose
        where purpose_code = '100' and year = 2024
        order by raw_value desc
        limit 10
    )
group by year, nationality_name
order by year
```

<LineChart
    data={top10_trend}
    x=year
    y=total_entries
    series=nationality_name
    title="主要国 入国者数の年次推移（短期滞在 Top 10）"
    yAxisTitle="入国者数（人）"
    xAxisTitle="年"
    yFmt=num0
/>

---

## 注目カテゴリ: ワーキング・ホリデー

```sql wh_by_country
select
    nationality_name,
    sum(raw_value) as total_entries
from japan_stats.mart_immigration_by_purpose
where purpose_code = '200'
    and year = ${inputs.selected_year.value}
    and raw_value > 0
    and region like '${inputs.selected_region.value}'
group by nationality_name
order by total_entries desc
limit 20
```

```sql wh_trend
select
    year,
    sum(raw_value) as total_entries
from japan_stats.mart_immigration_by_purpose
where purpose_code = '200'
group by year
order by year
```

<LineChart
    data={wh_trend}
    x=year
    y=total_entries
    title="ワーキング・ホリデー 入国者数の推移"
    yAxisTitle="入国者数（人）"
    xAxisTitle="年"
    yFmt=num0
/>

<BarChart
    data={wh_by_country}
    x=nationality_name
    y=total_entries
    title="ワーキング・ホリデー 国籍別ランキング（{inputs.selected_year.value}年）"
    yAxisTitle="入国者数（人）"
    swapXY=true
    sort=false
    yFmt=num0
/>

---

<LastRefreshed />

<small>データ出典：<a href="https://www.e-stat.go.jp/" target="_blank">e-Stat（政府統計の総合窓口）</a> 出入国管理統計（法務省）</small>
