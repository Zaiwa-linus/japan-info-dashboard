# Marts 層のサンプルコード

## ワイドテーブルの例

```sql
-- [責務] 4業態の月次販売データを都道府県×年月×業態のワイドテーブルに変換する
-- [ユニークキー] area_code, store_type_name, year_month
-- [入力] int_retail_sales

select
    area_code,
    area_name,
    year,
    month,
    year_month,
    max(case when indicator_name = '販売額' then value end) as sales_value,
    max(case when indicator_name = '店舗数' then value end) as store_count_value
from {{ ref('int_retail_sales') }}
group by area_code, area_name, year, month, year_month
```
