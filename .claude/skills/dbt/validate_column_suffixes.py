"""
dbt staging モデルの列名サフィックスバリデーション

staging SQL ファイルの SELECT 句内の列エイリアスが、
許可されたサフィックスのいずれかで終わっているかをチェックする。

許可サフィックス: _code, _value, _name, _day, _month, _year, _fyear, _period_raw_code, _period_raw_name
例外: unit, value（サフィックスなしで許可）

Usage:
    uv run python .claude/skills/dbt/validate_column_suffixes.py [ファイルパス...]

    引数なしの場合、dbt_project/models/staging/stg_*.sql を全件チェック。
"""

import glob
import re
import sys

ALLOWED_SUFFIXES = ("_period_raw_code", "_period_raw_name", "_code", "_value", "_name", "_day", "_month", "_year", "_fyear")
ALLOWED_EXACT: set[str] = set()

# SQL の型名（cast(... as TYPE) で使われるもの）
SQL_TYPES = {
    "int", "integer", "bigint", "smallint", "tinyint",
    "double", "float", "real", "decimal", "numeric",
    "varchar", "char", "text", "string",
    "boolean", "bool",
    "date", "timestamp", "datetime", "time",
}


def extract_column_aliases(sql_text: str) -> list[tuple[int, str]]:
    """SQL テキストから SELECT 句の列エイリアスを抽出する。

    cast/try_cast の型指定、CTE名、テーブルエイリアスを除外する。
    """
    aliases = []

    for i, line in enumerate(sql_text.splitlines(), start=1):
        stripped = line.strip()

        # コメント行はスキップ
        if stripped.startswith("--"):
            continue

        # FROM/JOIN 行はスキップ（テーブルエイリアス）
        if re.match(
            r"^(from|join|left\s+join|inner\s+join|cross\s+join|right\s+join)\s+",
            stripped,
            re.IGNORECASE,
        ):
            continue

        # CTE 定義行はスキップ（with xxx as (, yyy as (）
        if re.match(r"^(with\s+)?\w+\s+as\s*\(", stripped, re.IGNORECASE):
            continue
        if re.match(r"^,?\s*\w+\s+as\s*\(", stripped, re.IGNORECASE):
            continue

        # GROUP BY / ORDER BY / WHERE 以降はスキップ
        if re.match(r"^(group\s+by|order\s+by|where|having|limit)\b", stripped, re.IGNORECASE):
            continue

        # cast(... as TYPE) / try_cast(... as TYPE) 内の TYPE を除外するため、
        # まず cast 式を除去したテキストで alias を検出する
        cleaned = re.sub(
            r"(try_)?cast\s*\([^)]*\bas\s+\w+\)",
            "CAST_REMOVED",
            line,
            flags=re.IGNORECASE,
        )

        # "as alias_name" パターンを検出
        for match in re.finditer(r"\bas\s+(\w+)", cleaned, re.IGNORECASE):
            alias = match.group(1)

            # CAST_REMOVED の一部を拾ったらスキップ
            if alias == "CAST_REMOVED":
                continue

            # CTE参照をスキップ（as の直後に ( がある場合）
            pos = match.end()
            rest = cleaned[pos:].strip()
            if rest.startswith("("):
                continue

            aliases.append((i, alias))

    return aliases


def validate_file(filepath: str) -> list[str]:
    """1ファイルをバリデーションし、エラーメッセージのリストを返す。"""
    with open(filepath) as f:
        sql_text = f.read()

    aliases = extract_column_aliases(sql_text)
    errors = []

    for line_no, alias in aliases:
        if alias in ALLOWED_EXACT:
            continue
        if any(alias.endswith(suffix) for suffix in ALLOWED_SUFFIXES):
            continue
        errors.append(
            f"  L{line_no}: '{alias}' は許可されたサフィックス "
            f"({', '.join(ALLOWED_SUFFIXES)}) で終わっていません"
        )

    return errors


def main() -> int:
    if len(sys.argv) > 1:
        files = sys.argv[1:]
    else:
        files = sorted(
            glob.glob("dbt_project/models/staging/stg_*.sql")
        )

    if not files:
        print("チェック対象のファイルが見つかりません。")
        return 1

    total_errors = 0
    for filepath in files:
        errors = validate_file(filepath)
        if errors:
            print(f"❌ {filepath}")
            for err in errors:
                print(err)
            total_errors += len(errors)
        else:
            print(f"✅ {filepath}")

    print()
    if total_errors > 0:
        print(f"合計 {total_errors} 件のサフィックス違反が見つかりました。")
        return 1
    else:
        print("すべてのステージングモデルのサフィックスが正しいです。")
        return 0


if __name__ == "__main__":
    sys.exit(main())
