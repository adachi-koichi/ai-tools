---
name: miro
description: Miroボードの操作を行います。ボードの情報取得、ダイアグラム作成、アイテム管理などをAPI経由で実行します。
---

# Miro Board Operations（REST API版）

## 概要

Miro REST APIを使用してボードを操作するスキルです。

## セットアップ

### 1. アクセストークンの取得

1. [Miro Developer Portal](https://miro.com/app/settings/user-profile/apps) でアプリを作成
2. 必要なスコープを設定：
   - `boards:read` - ボード読み取り
   - `boards:write` - ボード作成・編集
3. アクセストークンを取得

### 2. 環境変数の設定

```bash
export MIRO_ACCESS_TOKEN="your_access_token_here"
```

または `.env.local` ファイルに記載：

```
MIRO_ACCESS_TOKEN=your_access_token_here
```

## API エンドポイント一覧

| 操作 | メソッド | エンドポイント |
|------|----------|----------------|
| ボード一覧取得 | GET | `/v2/boards` |
| ボード作成 | POST | `/v2/boards` |
| ボード取得 | GET | `/v2/boards/{board_id}` |
| ボード更新 | PATCH | `/v2/boards/{board_id}` |
| ボード削除 | DELETE | `/v2/boards/{board_id}` |
| アイテム一覧取得 | GET | `/v2/boards/{board_id}/items` |
| 図形作成 | POST | `/v2/boards/{board_id}/shapes` |
| 図形取得 | GET | `/v2/boards/{board_id}/shapes/{item_id}` |
| 図形更新 | PATCH | `/v2/boards/{board_id}/shapes/{item_id}` |
| 図形削除 | DELETE | `/v2/boards/{board_id}/shapes/{item_id}` |
| 付箋作成 | POST | `/v2/boards/{board_id}/sticky_notes` |
| テキスト作成 | POST | `/v2/boards/{board_id}/texts` |
| コネクタ作成 | POST | `/v2/boards/{board_id}/connectors` |
| フレーム作成 | POST | `/v2/boards/{board_id}/frames` |

## 基本操作

### ボード作成

```bash
./miro.sh create-board "ボード名" "説明文"
```

**curl直接実行：**
```bash
curl -X POST "https://api.miro.com/v2/boards" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "新しいボード",
    "description": "ボードの説明"
  }'
```

### ボード更新

```bash
./miro.sh update-board <board_id> "新しい名前"
```

**curl直接実行：**
```bash
curl -X PATCH "https://api.miro.com/v2/boards/${BOARD_ID}" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "更新後の名前",
    "description": "更新後の説明"
  }'
```

### ボード一覧取得

```bash
./miro.sh list-boards
```

**curl直接実行：**
```bash
curl -X GET "https://api.miro.com/v2/boards" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}"
```

### ボード情報取得

```bash
./miro.sh get-board <board_id>
```

**curl直接実行：**
```bash
curl -X GET "https://api.miro.com/v2/boards/${BOARD_ID}" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}"
```

## 図形操作

### 図形作成

```bash
./miro.sh create-shape <board_id> <shape_type> <content> [x] [y]
```

**図形タイプ：**
- `rectangle` - 長方形
- `round_rectangle` - 角丸長方形
- `circle` - 円
- `triangle` - 三角形
- `rhombus` - ひし形
- `parallelogram` - 平行四辺形
- `trapezoid` - 台形
- `pentagon` - 五角形
- `hexagon` - 六角形
- `octagon` - 八角形
- `wedge_round_rectangle_callout` - 吹き出し
- `star` - 星形
- `flow_chart_*` - フローチャート用図形

**curl直接実行：**
```bash
curl -X POST "https://api.miro.com/v2/boards/${BOARD_ID}/shapes" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "shape": "rectangle",
      "content": "<p>テキスト内容</p>"
    },
    "style": {
      "fillColor": "#ffffff",
      "fillOpacity": "1.0",
      "fontFamily": "arial",
      "fontSize": "14",
      "borderColor": "#1a1a1a",
      "borderWidth": "2",
      "borderOpacity": "1.0",
      "borderStyle": "normal",
      "textAlign": "center",
      "textAlignVertical": "middle",
      "color": "#1a1a1a"
    },
    "position": {
      "x": 0,
      "y": 0,
      "origin": "center"
    },
    "geometry": {
      "width": 200,
      "height": 100
    }
  }'
```

### 図形更新

```bash
./miro.sh update-shape <board_id> <item_id> <new_content>
```

**curl直接実行：**
```bash
curl -X PATCH "https://api.miro.com/v2/boards/${BOARD_ID}/shapes/${ITEM_ID}" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "content": "<p>更新後のテキスト</p>"
    }
  }'
```

### 図形削除

```bash
./miro.sh delete-shape <board_id> <item_id>
```

**curl直接実行：**
```bash
curl -X DELETE "https://api.miro.com/v2/boards/${BOARD_ID}/shapes/${ITEM_ID}" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}"
```

## 付箋操作

### 付箋作成

```bash
./miro.sh create-sticky <board_id> <content> [color] [x] [y]
```

**色オプション：**
- `gray`, `light_yellow`, `yellow`, `orange`, `light_green`
- `green`, `dark_green`, `cyan`, `light_pink`, `pink`
- `violet`, `red`, `light_blue`, `blue`, `dark_blue`, `black`

**curl直接実行：**
```bash
curl -X POST "https://api.miro.com/v2/boards/${BOARD_ID}/sticky_notes" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "content": "付箋の内容",
      "shape": "square"
    },
    "style": {
      "fillColor": "light_yellow",
      "textAlign": "center",
      "textAlignVertical": "middle"
    },
    "position": {
      "x": 0,
      "y": 0,
      "origin": "center"
    }
  }'
```

## テキスト操作

### テキスト作成

```bash
./miro.sh create-text <board_id> <content> [x] [y]
```

**curl直接実行：**
```bash
curl -X POST "https://api.miro.com/v2/boards/${BOARD_ID}/texts" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "content": "<p>テキスト内容</p>"
    },
    "style": {
      "color": "#1a1a1a",
      "fillOpacity": "1.0",
      "fontFamily": "arial",
      "fontSize": "14",
      "textAlign": "left"
    },
    "position": {
      "x": 0,
      "y": 0,
      "origin": "center"
    }
  }'
```

## コネクタ操作

### コネクタ作成（図形間を接続）

```bash
./miro.sh create-connector <board_id> <start_item_id> <end_item_id>
```

**curl直接実行：**
```bash
curl -X POST "https://api.miro.com/v2/boards/${BOARD_ID}/connectors" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "startItem": {
      "id": "START_ITEM_ID"
    },
    "endItem": {
      "id": "END_ITEM_ID"
    },
    "style": {
      "strokeColor": "#1a1a1a",
      "strokeWidth": "2",
      "strokeStyle": "normal",
      "startStrokeCap": "none",
      "endStrokeCap": "stealth"
    },
    "shape": "curved"
  }'
```

## フレーム操作

### フレーム作成

```bash
./miro.sh create-frame <board_id> <title> [x] [y] [width] [height]
```

**curl直接実行：**
```bash
curl -X POST "https://api.miro.com/v2/boards/${BOARD_ID}/frames" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "title": "フレームタイトル",
      "format": "custom"
    },
    "style": {
      "fillColor": "#ffffff"
    },
    "position": {
      "x": 0,
      "y": 0,
      "origin": "center"
    },
    "geometry": {
      "width": 800,
      "height": 600
    }
  }'
```

## アイテム一覧取得

```bash
./miro.sh list-items <board_id> [type]
```

**curl直接実行：**
```bash
curl -X GET "https://api.miro.com/v2/boards/${BOARD_ID}/items?limit=50" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}"
```

## スタイル設定例

### 色コード

```json
{
  "fillColor": "#ffffff",      // 背景色
  "borderColor": "#1a1a1a",    // 枠線色
  "color": "#1a1a1a"           // テキスト色
}
```

### フォント設定

```json
{
  "fontFamily": "arial",       // arial, cursive, abril_fatface, etc.
  "fontSize": "14",            // 10-288
  "textAlign": "center",       // left, center, right
  "textAlignVertical": "middle" // top, middle, bottom
}
```

### 枠線設定

```json
{
  "borderWidth": "2",          // 1-24
  "borderStyle": "normal",     // normal, dotted, dashed
  "borderOpacity": "1.0"       // 0.0-1.0
}
```

## ワークフロー例

### フローチャート作成

```bash
# 1. ボード作成
BOARD_ID=$(./miro.sh create-board "フローチャート" | jq -r '.id')

# 2. フレーム作成
./miro.sh create-frame $BOARD_ID "プロセスフロー" 0 0 1200 800

# 3. 図形作成
START_ID=$(./miro.sh create-shape $BOARD_ID "circle" "開始" -400 0 | jq -r '.id')
PROCESS_ID=$(./miro.sh create-shape $BOARD_ID "rectangle" "処理" 0 0 | jq -r '.id')
END_ID=$(./miro.sh create-shape $BOARD_ID "circle" "終了" 400 0 | jq -r '.id')

# 4. コネクタで接続
./miro.sh create-connector $BOARD_ID $START_ID $PROCESS_ID
./miro.sh create-connector $BOARD_ID $PROCESS_ID $END_ID
```

### ブレインストーミングボード

```bash
# 1. ボード作成
BOARD_ID=$(./miro.sh create-board "ブレインストーミング" | jq -r '.id')

# 2. 中心トピック
./miro.sh create-sticky $BOARD_ID "中心テーマ" "yellow" 0 0

# 3. アイデア付箋を配置
./miro.sh create-sticky $BOARD_ID "アイデア1" "light_green" -200 -150
./miro.sh create-sticky $BOARD_ID "アイデア2" "light_blue" 200 -150
./miro.sh create-sticky $BOARD_ID "アイデア3" "light_pink" -200 150
./miro.sh create-sticky $BOARD_ID "アイデア4" "orange" 200 150
```

## レート制限

| レベル | 制限 |
|--------|------|
| Level 1 | 2000リクエスト/分 |
| Level 2 | 200リクエスト/分 |
| Level 3 | 100リクエスト/分 |

ボード作成はLevel 3、図形作成はLevel 2です。

## エラーハンドリング

```bash
# レスポンスのステータスコードを確認
response=$(curl -s -w "\n%{http_code}" -X GET "https://api.miro.com/v2/boards" \
  -H "Authorization: Bearer ${MIRO_ACCESS_TOKEN}")
status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$status_code" -ne 200 ]; then
  echo "Error: $status_code"
  echo "$body" | jq '.message'
fi
```

## 参考リンク

- [Miro REST API リファレンス](https://developers.miro.com/reference/api-reference)
- [認証ガイド](https://developers.miro.com/docs/getting-started-with-oauth)
- [図形タイプ一覧](https://developers.miro.com/reference/create-shape-item)
