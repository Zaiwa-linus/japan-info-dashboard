-- [責務] 入国目的コードに目的カテゴリ・地域分類を付与し、地域集約行を除外する
-- [ユニークキー] purpose_code, nationality_code, year
-- [入力] stg_immigration_by_purpose

with base as (
    select
        purpose_code,
        purpose_name,
        nationality_code,
        nationality_name,
        year_code,
        cast(left(cast(year_code as varchar), 4) as int) as year,
        raw_value
    from {{ ref('stg_immigration_by_purpose') }}
    where raw_value is not null
),

-- 地域集約コード（総数・大陸）を除外し、個別国のみ残す
country_level as (
    select *
    from base
    where nationality_code not in (
        '50000',  -- 総数
        '50040',  -- アジア
        '50490',  -- ヨーロッパ
        '51060',  -- アフリカ
        '51610',  -- 北アメリカ
        '51850',  -- 南アメリカ
        '51980'   -- オセアニア
    )
),

-- 入国目的の大分類・地域分類を付与
with_category as (
    select
        *,
        case
            when purpose_code in ('100', '110', '120', '130', '140', '150')
                then '短期滞在'
            when purpose_code >= '160' and purpose_code < '300'
                then '特定活動'
            when purpose_code >= '300' and purpose_code < '330'
                then '日本人の配偶者等'
            when purpose_code >= '330'
                then '定住者'
            else '短期滞在'
        end as purpose_category,
        case
            when purpose_code in ('100', '160', '300', '330') then true
            else false
        end as is_subtotal,
        case
            when nationality_code >= '50050' and nationality_code < '50490' then 'アジア'
            when nationality_code >= '50490' and nationality_code < '51060' then 'ヨーロッパ'
            when nationality_code >= '51060' and nationality_code < '51610' then 'アフリカ'
            when nationality_code >= '51610' and nationality_code < '51850' then '北アメリカ'
            when nationality_code >= '51850' and nationality_code < '51980' then '南アメリカ'
            when nationality_code >= '51980' and nationality_code < '52140' then 'オセアニア'
            when nationality_code = '52140' then 'その他'
            else 'その他'
        end as region
    from country_level
)

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
from with_category
