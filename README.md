# japan-info-dashboard

## セットアップ

```bash
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

## 環境変数

| 変数名 | 説明 |
|--------|------|
| `ESTAT_API_APPID` | e-Stat API の AppID |

`.env` ファイルに記載するか、直接 export してください。

```bash
export ESTAT_API_APPID="あなたのAppID"
```