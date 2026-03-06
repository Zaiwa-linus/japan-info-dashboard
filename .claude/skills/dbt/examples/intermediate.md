# Intermediate 層のサンプルコード

## ITM ルール別 OK/NG 例

### ルール1: NULL 値の完全排除

```sql
-- OK: NULL 行を除外
select * from {{ ref('stg_xxx') }}
where raw_value is not null

-- NG: NULL が残ったまま出力
select * from {{ ref('stg_xxx') }}
```

### ルール2: 指標区分をユニークキーに含めない

```sql
-- NG: 指標名がキーの一部になっている（縦持ち）
-- ユニークキー: area_code, year_month, indicator_name
select area_code, year_month, indicator_name, value
from ...

-- OK: 指標を列に展開（横持ち）
-- ユニークキー: area_code, year_month
select
    area_code,
    year_month,
    max(case when indicator_name = '売上' then value end) as sales_value,
    max(case when indicator_name = '利益' then value end) as profit_value
from ...
group by area_code, year_month
```

### ルール3: 横持ち時のデータ期間不一致はモデルを分離する

```
-- NG: 売上は3年分、損失は2年分 → 損失列に NULL が発生する
int_wide_xxx.sql  (売上 + 損失を1テーブルに横持ち)

-- OK: データ期間が揃わないならモデルを分離
int_wide_xxx_sales.sql   (売上のみ、3年分)
int_wide_xxx_loss.sql    (損失のみ、2年分)
```

### ルール4: P-key の値は MECE であること

```sql
-- NG: 男女合計と内訳が混在
select * from {{ ref('stg_xxx') }}
-- gender_name: '男', '女', '男女'  ← MECE でない

-- OK: 合計行を除外して内訳のみ
select * from {{ ref('stg_xxx') }}
where gender_name != '男女'
```

### ルール5: value 列は合計が意味をなすこと

```sql
-- NG: 異なる指標が同じ value 列に混在
select area_code, indicator_name, value
from ...
-- indicator_name: '発注数', '売上高'  ← value の合計が無意味

-- OK: 指標ごとに列を分ける
select
    area_code,
    max(case when indicator_name = '発注数' then value end) as order_count_value,
    max(case when indicator_name = '売上高' then value end) as sales_value
from ...
group by area_code
```

### ルール6: 月次データの日付型

```sql
-- staging の year / month から DATE 型を生成する例
make_date(year::int, month::int, 1) as year_month

-- time_code (例: '2024000101') から生成する例
make_date(
    substring(time_code, 1, 4)::int,
    substring(time_code, 7, 2)::int,
    1
) as year_month
```

## SQL 冒頭コメントの例

```sql
-- [責務] 4業態の月次販売データを統合し、月次データのみに絞り込む
-- [ユニークキー] area_code, store_type_name, time_code
-- [入力] stg_convenience_store_sales, stg_electronics_store_sales, ...
```

## prep（前処理）の例

```sql
-- [責務] 2022年度と2023年度の調査データを統合する
-- [ユニークキー] area_code, survey_year
-- [入力] stg_survey_2022, stg_survey_2023

with fy2022 as (
    select * from {{ ref('stg_survey_2022') }}
),
fy2023 as (
    select * from {{ ref('stg_survey_2023') }}
)
select * from fy2022
union all
select * from fy2023
```

## logic（ビジネスロジック）の例

```sql
-- [責務] 入国目的コードに目的カテゴリ・地域分類を付与し、集約行を除外する
-- [ユニークキー] purpose_code, nationality_code, year_code
-- [入力] int_prep_immigration

select
    *,
    case
        when purpose_code in ('100', '110') then '短期滞在'
        when purpose_code >= '160' then '特定活動'
    end as purpose_category_name
from {{ ref('int_prep_immigration') }}
```
