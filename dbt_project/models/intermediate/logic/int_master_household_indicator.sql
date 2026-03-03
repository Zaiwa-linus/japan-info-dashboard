-- [責務] 家計指標の冗長な名称をダッシュボード表示用の短縮名にマッピングする
-- [ユニークキー] indicator_code
-- [入力] stg_household

with raw_master as (
    select distinct
        indicator_code,
        indicator_name
    from {{ ref('stg_household') }}
),

renamed as (
    select
        indicator_code,
        indicator_name,
        case indicator_name
            when 'L5101_耐久消費財所有数量（応接セット）' then '応接セット'
            when 'L5103_耐久消費財所有数量（二人以上の世帯）（電子レンジ（電子オーブンレンジを含む））' then '電子レンジ'
            when 'L5104_耐久消費財所有数量（二人以上の世帯）（ルームエアコン）' then 'ルームエアコン'
            when 'L5105_耐久消費財所有数量（ステレオ）（全世帯）' then 'ステレオ'
            when 'L5106_耐久消費財所有数量（ビデオテープレコーダ）（全世帯）' then 'ビデオテープレコーダ'
            when 'L5107_耐久消費財所有数量（二人以上の世帯）（ピアノ・電子ピアノ）' then 'ピアノ・電子ピアノ'
            when 'L5108_耐久消費財所有数量（二人以上の世帯）（自動車）' then '自動車'
            when 'L5109_耐久消費財所有数量（二人以上の世帯）（オートバイ・スクーター）' then 'オートバイ・スクーター'
            when 'L5110_耐久消費財所有数量（給湯器（ガス瞬間湯沸器を除く））（全世帯）' then '給湯器'
            when 'L5111_耐久消費財所有数量（二人以上の世帯）（温水洗浄便座）' then '温水洗浄便座'
            when 'L5112_耐久消費財所有数量（二人以上の世帯）（携帯電話（PHSを含み，スマートフォンを除く））' then '携帯電話（スマホ除く）'
            when 'L5113_耐久消費財所有数量（ファクシミリ（コピー付を含む））' then 'ファクシミリ'
            when 'L5114_耐久消費財所有数量（二人以上の世帯）（パソコン）' then 'パソコン'
            when 'L5115_耐久消費財所有数量（二人以上の世帯）（ビデオカメラ）' then 'ビデオカメラ'
            when 'L5116_耐久消費財所有数量（ステレオセット又はCD・MDラジオカセット）' then 'ステレオ・ラジカセ'
            when 'L5117_耐久消費財所有数量（二人以上の世帯）（ビデオレコーダ（DVD ブルーレイを含む））' then 'ビデオレコーダ（DVD・BD）'
            when 'L5118_耐久消費財所有数量（二人以上の世帯）（ハイブリッド・電気自動車（国産））' then 'HV・EV（国産）'
            when 'L5119_耐久消費財所有数量（二人以上の世帯）（床暖房）' then '床暖房'
            when 'L5120_耐久消費財所有数量（二人以上の世帯）（太陽光発電システム）' then '太陽光発電'
            when 'L5121_耐久消費財所有数量（二人以上の世帯）（タブレット端末）' then 'タブレット端末'
            when 'L5122_耐久消費財所有数量（二人以上の世帯）（スマートフォン）' then 'スマートフォン'
            when 'L5123_耐久消費財所有数量（二人以上の世帯）（パソコン（ノート型（モバイル・ネットブックを含む）））' then 'ノートPC'
            when 'L5124_耐久消費財所有数量（二人以上の世帯）（パソコン（デスクトップ型））' then 'デスクトップPC'
            else indicator_name
        end as indicator_short_name
    from raw_master
)

select
    indicator_code,
    indicator_name,
    indicator_short_name
from renamed
