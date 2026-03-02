-- 新規入国外国人マート
-- Evidence から直接参照する最終テーブル

select
    purpose_code,
    purpose_name,
    purpose_category,
    is_subtotal,
    nationality_code,
    nationality_name,
    region,
    year,
    value
from {{ ref('int_immigration_by_purpose') }}
