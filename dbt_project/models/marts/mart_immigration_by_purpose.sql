-- [責務] 新規入国外国人データを Evidence 用に出力する
-- [ユニークキー] purpose_code, nationality_code, year
-- [入力] int_immigration_by_purpose

select
    purpose_code,
    purpose_name,
    purpose_category,
    is_subtotal,
    nationality_code,
    nationality_name,
    region,
    year,
    raw_value
from {{ ref('int_immigration_by_purpose') }}
