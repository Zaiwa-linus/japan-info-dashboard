"""
column_summary.yml を基に sources.yml と _stg_*.yml を生成するスクリプト。

Usage:
    python scripts/generate_staging_yaml.py
"""

import yaml
import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent
DATA_DIR = PROJECT_ROOT / "data"
STAGING_DIR = PROJECT_ROOT / "dbt_project" / "models" / "staging"

# ユニーク値100件以下のカラムのみ accepted_values テスト対象
MAX_UNIQUE_FOR_TEST = 100

# テーブルID → ステージングモデル名 のマッピング
TABLE_MODEL_MAP = {
    "0000010103": "stg_economic_base",
    "0000010112": "stg_household",
    "0002210008": "stg_savings_debt",
    "0004026264": "stg_population",
    "0004032502": "stg_convenience_store_sales",
    "0004032505": "stg_electronics_store_sales",
    "0004032508": "stg_drugstore_sales",
    "0004032511": "stg_home_center_sales",
    "0003288053": "stg_immigration_by_purpose",
    "0003288041": "stg_port_entry_exit",
    "0004026265": "stg_birth_death_by_prefecture",
    "0004026702": "stg_population_migration",
    "0003441258": "stg_consumer_price_index",
    "0003195002": "stg_crime_statistics",
    "0003288314": "stg_ship_tourism_landing",
}

# テーブル説明
TABLE_DESCRIPTIONS = {
    "0000010103": "社会・人口統計体系 - Ｃ 経済基盤（都道府県別）",
    "0000010112": "社会・人口統計体系 - Ｌ 家計（都道府県別）",
    "0002210008": "家計調査 - 貯蓄・負債（都市階級・地方・県庁所在市別）",
    "0004026264": "人口推計 - 都道府県・男女別人口",
    "0004032502": "商業動態統計調査 - コンビニエンスストア 都道府県別販売額等",
    "0004032505": "商業動態統計調査 - 家電大型専門店 都道府県別販売額等",
    "0004032508": "商業動態統計調査 - ドラッグストア 都道府県別販売額等",
    "0004032511": "商業動態統計調査 - ホームセンター 都道府県別販売額等",
    "0003288053": "出入国管理統計 - 国籍・地域別 入国目的別 新規入国外国人",
    "0003288041": "出入国管理統計 - 港別 出入国者",
    "0004026265": "人口推計 - 都道府県別 出生児数・死亡者数",
    "0004026702": "住民基本台帳人口移動報告 - 移動前の住所地別転入者数",
    "0003441258": "小売物価統計調査 - 都道府県別 消費者物価地域差指数（10大費目別）",
    "0003195002": "犯罪統計 - 都道府県別 刑法犯 認知・検挙件数",
    "0003288314": "出入国管理統計 - 船舶観光上陸許可（国籍・港別）",
}

# カラムマッピング: テーブルID → [(日本語名, 英語名, description), ...]
# value/raw_value は全モデル共通で最後に追加
COLUMN_MAPPINGS = {
    "0004026264": [
        ("表章項目_code", "item_code", "表章項目コード"),
        ("表章項目", "item_name", "表章項目名称"),
        ("人口及び人口増減_code", "population_type_code", "人口及び人口増減の分類コード"),
        ("人口及び人口増減", "population_type_name", "人口及び人口増減の分類名称"),
        ("男女別_code", "gender_code", "男女別コード"),
        ("男女別", "gender_name", "男女別の名称"),
        ("人口_code", "population_category_code", "人口区分コード"),
        ("人口", "population_category_name", "人口区分の名称"),
        ("全国・都道府県_code", "area_code", "全国・都道府県コード"),
        ("全国・都道府県", "area_name", "全国・都道府県名"),
        ("時間軸（年間）_code", "year_code", "年次コード"),
        ("時間軸（年間）", "year_name", "年次の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
    "0000010103": [
        ("観測値_code", "observation_code", "観測値の分類コード"),
        ("観測値", "observation_name", "観測値の分類名称"),
        ("Ｃ　経済基盤_code", "indicator_code", "経済基盤指標の分類コード"),
        ("Ｃ　経済基盤", "indicator_name", "経済基盤指標の名称"),
        ("地域_code", "area_code", "都道府県コード"),
        ("地域", "area_name", "都道府県名"),
        ("調査年_code", "year_code", "調査年コード"),
        ("調査年", "year_name", "調査年の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
    "0000010112": [
        ("観測値_code", "observation_code", "観測値の分類コード"),
        ("観測値", "observation_name", "観測値の分類名称"),
        ("Ｌ　家計_code", "indicator_code", "家計指標の分類コード"),
        ("Ｌ　家計", "indicator_name", "家計指標の名称"),
        ("地域_code", "area_code", "都道府県コード"),
        ("地域", "area_name", "都道府県名"),
        ("調査年_code", "year_code", "調査年コード"),
        ("調査年", "year_name", "調査年の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
    "0002210008": [
        ("表章項目_code", "item_code", "表章項目コード"),
        ("表章項目", "item_name", "表章項目名称"),
        ("貯蓄・負債_code", "category_code", "貯蓄・負債の分類コード"),
        ("貯蓄・負債", "category_name", "貯蓄・負債の分類名称"),
        ("世帯区分_code", "household_type_code", "世帯区分コード"),
        ("世帯区分", "household_type_name", "世帯区分の名称"),
        ("地域区分_code", "area_code", "地域区分コード"),
        ("地域区分", "area_name", "地域区分の名称"),
        ("時間軸（年次）_code", "year_code", "年次コード"),
        ("時間軸（年次）", "year_name", "年次の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
    "0004032502": [
        ("単位_db_code", "unit_code", "単位コード"),
        ("単位_db", "unit_name", "単位の名称"),
        ("表頭_集計項目_db_code", "header_item_code", "表頭集計項目コード"),
        ("表頭_集計項目_db", "header_item_name", "表頭集計項目の名称"),
        ("表側_集計項目_db_code", "side_item_code", "表側集計項目コード"),
        ("表側_集計項目_db", "side_item_name", "表側集計項目の名称"),
        ("都道府県_code", "area_code", "都道府県コード"),
        ("都道府県", "area_name", "都道府県名"),
        ("時間軸_db_code", "time_code", "時間軸コード"),
        ("時間軸_db", "time_name", "時間軸の表示名称"),
        ("unit", None, "値の単位（CSVの元カラム）"),
    ],
    "0004032505": [
        ("単位_db_code", "unit_code", "単位コード"),
        ("単位_db", "unit_name", "単位の名称"),
        ("表頭_集計項目_db_code", "header_item_code", "表頭集計項目コード"),
        ("表頭_集計項目_db", "header_item_name", "表頭集計項目の名称"),
        ("表側_集計項目_db_code", "side_item_code", "表側集計項目コード"),
        ("表側_集計項目_db", "side_item_name", "表側集計項目の名称"),
        ("都道府県_code", "area_code", "都道府県コード"),
        ("都道府県", "area_name", "都道府県名"),
        ("時間軸_db_code", "time_code", "時間軸コード"),
        ("時間軸_db", "time_name", "時間軸の表示名称"),
        ("unit", None, "値の単位（CSVの元カラム）"),
    ],
    "0004032508": [
        ("単位_db_code", "unit_code", "単位コード"),
        ("単位_db", "unit_name", "単位の名称"),
        ("表頭_集計項目_db_code", "header_item_code", "表頭集計項目コード"),
        ("表頭_集計項目_db", "header_item_name", "表頭集計項目の名称"),
        ("表側_集計項目_db_code", "side_item_code", "表側集計項目コード"),
        ("表側_集計項目_db", "side_item_name", "表側集計項目の名称"),
        ("都道府県_code", "area_code", "都道府県コード"),
        ("都道府県", "area_name", "都道府県名"),
        ("時間軸_db_code", "time_code", "時間軸コード"),
        ("時間軸_db", "time_name", "時間軸の表示名称"),
        ("unit", None, "値の単位（CSVの元カラム）"),
    ],
    "0004032511": [
        ("単位_db_code", "unit_code", "単位コード"),
        ("単位_db", "unit_name", "単位の名称"),
        ("表頭_集計項目_db_code", "header_item_code", "表頭集計項目コード"),
        ("表頭_集計項目_db", "header_item_name", "表頭集計項目の名称"),
        ("表側_集計項目_db_code", "side_item_code", "表側集計項目コード"),
        ("表側_集計項目_db", "side_item_name", "表側集計項目の名称"),
        ("都道府県_code", "area_code", "都道府県コード"),
        ("都道府県", "area_name", "都道府県名"),
        ("時間軸_db_code", "time_code", "時間軸コード"),
        ("時間軸_db", "time_name", "時間軸の表示名称"),
        ("unit", None, "値の単位（CSVの元カラム）"),
    ],
    "0003288053": [
        ("表章項目_code", "item_code", "表章項目コード"),
        ("表章項目", "item_name", "表章項目名称"),
        ("入国目的_code", "purpose_code", "入国目的コード"),
        ("入国目的", "purpose_name", "入国目的の名称"),
        ("国籍・地域_code", "nationality_code", "国籍・地域コード"),
        ("国籍・地域", "nationality_name", "国籍・地域の名称"),
        ("時間軸(年次)_code", "year_code", "年次コード"),
        ("時間軸(年次)", "year_name", "年次の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
    "0003288041": [
        ("表章項目_code", "item_code", "表章項目コード"),
        ("表章項目", "item_name", "表章項目名称"),
        ("出入国者_code", "traveler_type_code", "出入国者区分コード"),
        ("出入国者", "traveler_type_name", "出入国者区分の名称"),
        ("入国・出国_code", "direction_code", "入国・出国の方向コード"),
        ("入国・出国", "direction_name", "入国・出国の方向名称"),
        ("港_code", "port_code", "港コード"),
        ("港", "port_name", "港の名称"),
        ("時間軸(年次)_code", "year_code", "年次コード"),
        ("時間軸(年次)", "year_name", "年次の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
    "0004026265": [
        ("表章項目_code", "item_code", "表章項目コード"),
        ("表章項目", "item_name", "表章項目名称"),
        ("出生児数・死亡者数_code", "birth_death_code", "出生児数・死亡者数の分類コード"),
        ("出生児数・死亡者数", "birth_death_name", "出生児数・死亡者数の分類名称"),
        ("男女別_code", "gender_code", "男女別コード"),
        ("男女別", "gender_name", "男女別の名称"),
        ("日本人・外国人_code", "nationality_code", "日本人・外国人の区分コード"),
        ("日本人・外国人", "nationality_name", "日本人・外国人の区分名称"),
        ("全国・都道府県_code", "area_code", "全国・都道府県コード"),
        ("全国・都道府県", "area_name", "全国・都道府県名"),
        ("時間軸（年間）_code", "year_code", "年次コード"),
        ("時間軸（年間）", "year_name", "年次の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
    "0004026702": [
        ("表章項目_code", "item_code", "表章項目コード"),
        ("表章項目", "item_name", "表章項目名称"),
        ("移動後の住所地（現住地）2020～_code", "current_address_code", "移動後の住所地コード"),
        ("移動後の住所地（現住地）2020～", "current_address_name", "移動後の住所地名称"),
        ("国籍_code", "nationality_code", "国籍コード"),
        ("国籍", "nationality_name", "国籍の名称"),
        ("移動前の住所地（前住地）2020～_code", "previous_address_code", "移動前の住所地コード"),
        ("移動前の住所地（前住地）2020～", "previous_address_name", "移動前の住所地名称"),
        ("時間軸_code", "year_code", "年次コード"),
        ("時間軸", "year_name", "年次の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
    "0003441258": [
        ("表章項目_code", "item_code", "表章項目コード"),
        ("表章項目", "item_name", "表章項目名称"),
        ("10大費目_code", "expense_category_code", "10大費目コード"),
        ("10大費目", "expense_category_name", "10大費目の名称"),
        ("地域_code", "area_code", "地域コード"),
        ("地域", "area_name", "地域名"),
        ("時間軸(年)_code", "year_code", "年次コード"),
        ("時間軸(年)", "year_name", "年次の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
    "0003195002": [
        ("認知・検挙件数・検挙人員_code", "crime_metric_code", "認知・検挙件数・検挙人員の分類コード"),
        ("認知・検挙件数・検挙人員", "crime_metric_name", "認知・検挙件数・検挙人員の分類名称"),
        ("管区警察局_code", "police_district_code", "管区警察局コード"),
        ("管区警察局", "police_district_name", "管区警察局の名称"),
        ("時間軸(年次)_code", "year_code", "年次コード"),
        ("時間軸(年次)", "year_name", "年次の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
    "0003288314": [
        ("表章項目_code", "item_code", "表章項目コード"),
        ("表章項目", "item_name", "表章項目名称"),
        ("国籍・地域_code", "nationality_code", "国籍・地域コード"),
        ("国籍・地域", "nationality_name", "国籍・地域の名称"),
        ("港_code", "port_code", "港コード"),
        ("港", "port_name", "港の名称"),
        ("時間軸(年次)_code", "year_code", "年次コード"),
        ("時間軸(年次)", "year_name", "年次の表示名称"),
        ("unit", "unit_name", "値の単位"),
    ],
}

# モデルの description テンプレート
MODEL_DESCRIPTIONS = {
    "stg_population": "人口推計 - 都道府県・男女別人口。都道府県ごとの総人口・男女別人口および人口増減を整形したステージングモデル。",
    "stg_economic_base": "社会・人口統計体系 - Ｃ 経済基盤（都道府県別）。県内総生産額、県民所得など経済基盤指標を整形したステージングモデル。",
    "stg_household": "社会・人口統計体系 - Ｌ 家計（都道府県別）。都道府県ごとの消費支出・収入などの家計関連指標を整形したステージングモデル。",
    "stg_savings_debt": "家計調査 - 貯蓄・負債（都市階級・地方・県庁所在市別）。世帯の貯蓄・負債に関する指標を整形したステージングモデル。",
    "stg_convenience_store_sales": "商業動態統計調査 - コンビニエンスストア販売。都道府県別の販売額・店舗数等を整形したステージングモデル。",
    "stg_electronics_store_sales": "商業動態統計調査 - 家電大型専門店販売。都道府県別の販売額・店舗数等を整形したステージングモデル。",
    "stg_drugstore_sales": "商業動態統計調査 - ドラッグストア販売。都道府県別の販売額・店舗数等を整形したステージングモデル。",
    "stg_home_center_sales": "商業動態統計調査 - ホームセンター販売。都道府県別の販売額・店舗数等を整形したステージングモデル。",
    "stg_immigration_by_purpose": "出入国管理統計 - 国籍・地域別 入国目的別 新規入国外国人。在留資格別の入国外国人数を整形したステージングモデル。",
    "stg_port_entry_exit": "出入国管理統計 - 港別 出入国者。空港・港別の出入国者数を整形したステージングモデル。",
    "stg_birth_death_by_prefecture": "人口推計 - 都道府県別 出生児数・死亡者数。都道府県ごとの出生児数・死亡者数を整形したステージングモデル。",
    "stg_population_migration": "住民基本台帳人口移動報告 - 移動前の住所地別転入者数。市区町村間の人口移動データを整形したステージングモデル。",
    "stg_consumer_price_index": "小売物価統計調査 - 消費者物価地域差指数（10大費目別）。都道府県別の物価水準を整形したステージングモデル。",
    "stg_crime_statistics": "犯罪統計 - 都道府県別 刑法犯 認知・検挙件数。管区警察局別の犯罪統計を整形したステージングモデル。",
    "stg_ship_tourism_landing": "出入国管理統計 - 船舶観光上陸許可（国籍・港別）。クルーズ船による観光上陸者数を整形したステージングモデル。",
}

# 商業動態統計の表頭コードの違い
COMMERCIAL_HEADER_CODES = {
    "0004032502": ["01040100", "01040200"],  # 販売額, 店舗数
    "0004032505": ["01040110", "01040200"],  # 販売額等, 店舗数
    "0004032508": ["01040100", "01040200"],  # 販売額, 店舗数
    "0004032511": ["01040100", "01040200"],  # 販売額, 店舗数
}
COMMERCIAL_HEADER_NAMES = {
    "0004032502": ["販売額", "店舗数"],
    "0004032505": ["店舗数", "販売額等"],
    "0004032508": ["店舗数", "販売額"],
    "0004032511": ["店舗数", "販売額"],
}


def load_column_summary(table_id: str) -> dict:
    """column_summary.yml を読み込む"""
    path = DATA_DIR / table_id / "column_summary.yml"
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def make_description_with_values(base_desc: str, col_info: dict) -> str:
    """description にユニーク件数と値のサマリーを追加"""
    unique_count = col_info.get("unique_count", 0)
    values = col_info.get("values", [])

    if unique_count <= 5:
        vals_str = ", ".join(str(v) for v in values)
        return f"{base_desc}。{unique_count}種類: {vals_str}"
    else:
        return f"{base_desc}。{unique_count}種類"


def generate_sources_yml():
    """sources.yml を生成"""
    lines = []
    lines.append("version: 2")
    lines.append("")
    lines.append("sources:")
    lines.append('  - name: estat')
    lines.append('    description: "e-Stat APIから取得した統計データ（CSVファイル）"')
    lines.append("    meta:")
    lines.append('      external_location: "../data/{name}/{name}.csv"')
    lines.append("    tables:")

    for table_id in TABLE_MODEL_MAP:
        summary = load_column_summary(table_id)
        columns_info = summary.get("columns", {})

        lines.append(f'      - name: "{table_id}"')
        desc = TABLE_DESCRIPTIONS[table_id]
        lines.append(f'        description: "{desc}"')
        lines.append(f"        columns:")

        # カラムマッピングからカラム定義を生成
        mappings = COLUMN_MAPPINGS[table_id]
        for jp_name, _en_name, base_desc in mappings:
            col_info = columns_info.get(jp_name, {})
            full_desc = make_description_with_values(base_desc, col_info)

            # YAML のダブルクォート内のエスケープ
            full_desc_escaped = full_desc.replace('"', '\\"')
            jp_name_escaped = jp_name.replace('"', '\\"')

            lines.append(f'          - name: "{jp_name_escaped}"')
            lines.append(f'            description: "{full_desc_escaped}"')

        # value カラム
        val_info = columns_info.get("value", {})
        val_unique = val_info.get("unique_count", 0)
        lines.append(f'          - name: "value"')
        lines.append(f'            description: "指標の数値。{val_unique}種類"')

    return "\n".join(lines) + "\n"


def generate_stg_yml(table_id: str) -> str:
    """_stg_*.yml を生成"""
    model_name = TABLE_MODEL_MAP[table_id]
    summary = load_column_summary(table_id)
    columns_info = summary.get("columns", {})
    mappings = COLUMN_MAPPINGS[table_id]

    lines = []
    lines.append("version: 2")
    lines.append("")
    lines.append("models:")
    lines.append(f"  - name: {model_name}")

    model_desc = MODEL_DESCRIPTIONS[model_name]
    lines.append(f'    description: "{model_desc}"')
    lines.append("    columns:")

    for jp_name, en_name, base_desc in mappings:
        if en_name is None:
            # 商業動態統計の unit カラム（stg_*.sql では unit カラムを使わない）
            continue

        col_info = columns_info.get(jp_name, {})
        unique_count = col_info.get("unique_count", 0)
        values = col_info.get("values", [])

        # description 生成
        if unique_count > MAX_UNIQUE_FOR_TEST:
            desc = f"{base_desc}（{unique_count}種類のため accepted_values テスト対象外）"
        else:
            desc = base_desc

        desc_escaped = desc.replace('"', '\\"')
        lines.append(f"      - name: {en_name}")
        lines.append(f'        description: "{desc_escaped}"')

        # accepted_values テスト（100件以下のみ）
        if unique_count <= MAX_UNIQUE_FOR_TEST and unique_count > 0 and "..." not in values:
            lines.append("        tests:")
            lines.append("          - accepted_values:")

            # 値が少ない場合はインラインで
            if unique_count <= 5:
                vals_str = ", ".join(f'"{v}"' for v in sorted(values))
                lines.append(f"              values: [{vals_str}]")
            else:
                lines.append("              values:")
                for v in sorted(values):
                    v_escaped = str(v).replace('"', '\\"')
                    lines.append(f'                - "{v_escaped}"')

    # 商業動態統計: store_type_name カラム（リテラル値）
    store_type_names = {
        "stg_convenience_store_sales": "コンビニ",
        "stg_electronics_store_sales": "家電量販店",
        "stg_drugstore_sales": "ドラッグストア",
        "stg_home_center_sales": "ホームセンター",
    }
    if model_name in store_type_names:
        stn = store_type_names[model_name]
        lines.append("      - name: store_type_name")
        lines.append(f'        description: "業態名（固定値: {stn}）"')
        lines.append("        tests:")
        lines.append("          - accepted_values:")
        lines.append(f'              values: ["{stn}"]')

    # raw_value カラム（テスト対象外）
    lines.append("      - name: raw_value")
    lines.append('        description: "指標の数値（型キャスト済み）"')

    return "\n".join(lines) + "\n"


def main():
    # sources.yml 生成
    sources_content = generate_sources_yml()
    sources_path = STAGING_DIR / "sources.yml"
    with open(sources_path, "w", encoding="utf-8") as f:
        f.write(sources_content)
    print(f"Generated: {sources_path}")

    # _stg_*.yml 生成
    for table_id, model_name in TABLE_MODEL_MAP.items():
        yml_content = generate_stg_yml(table_id)
        yml_path = STAGING_DIR / f"_{model_name}.yml"
        with open(yml_path, "w", encoding="utf-8") as f:
            f.write(yml_content)
        print(f"Generated: {yml_path}")


if __name__ == "__main__":
    main()
