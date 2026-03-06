-- [責務] 気候指標を都道府県×年×指標の長形式で提供する
-- [ユニークキー] area_code, survey_year, indicator_code

select
    area_code,
    area_name,
    survey_year,
    indicator_code,
    case indicator_code
        when 'B4101' then '年平均気温'
        when 'B4102' then '最高気温'
        when 'B4103' then '最低気温'
        when 'B4104' then '快晴日数'
        when 'B4105' then '曇天日数'
        when 'B4106' then '雨天日数'
        when 'B4107' then '雪日数'
        when 'B4108' then '日照時間'
        when 'B4109' then '年間降水量'
        when 'B4110' then '最深積雪'
        when 'B4111' then '平均相対湿度'
        when 'B4112' then '最小相対湿度'
    end as indicator_label,
    case indicator_code
        when 'B4101' then '℃'
        when 'B4102' then '℃'
        when 'B4103' then '℃'
        when 'B4104' then '日'
        when 'B4105' then '日'
        when 'B4106' then '日'
        when 'B4107' then '日'
        when 'B4108' then '時間'
        when 'B4109' then 'mm'
        when 'B4110' then 'cm'
        when 'B4111' then '%'
        when 'B4112' then '%'
    end as unit,
    raw_value as value
from {{ ref('stg_natural_environment') }}
where indicator_code like 'B41%'
    and area_code != '00000'
    and raw_value is not null
