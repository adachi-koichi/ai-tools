---
name: agent-conversation-logger
description: |
  Agentとユーザーの会話をSQLiteデータベースに保存・管理するスキル。
  以下のトリガーで使用する:
  (1) ユーザーが「会話を保存」「ログを保存」「履歴を保存」と言った時
  (2) 重要な会話やデバッグが必要な会話を自動的に保存したい時
  (3) セッション終了時にまとめて会話を保存する時
  (4) 過去の会話を検索・参照したい時
  対応機能: メッセージ保存、セッション管理、検索、エクスポート(JSON/Markdown)
---

# Agent Conversation Logger

会話をSQLiteに保存し、後から検索・参照可能にする。

## データベース

保存先: `./conversations.db`

### スキーマ

**sessions テーブル**
- `id`: セッションID
- `created_at`: 作成日時
- `updated_at`: 更新日時
- `metadata`: メタデータ(JSON)

**messages テーブル**
- `id`: メッセージID
- `session_id`: セッションID
- `role`: user / assistant / system
- `content`: メッセージ内容
- `timestamp`: 日時
- `model`: モデル名
- `token_count`: トークン数
- `tools_used`: 使用ツール(JSON配列)
- `error_info`: エラー情報
- `metadata`: メタデータ(JSON)

## 使用方法

### メッセージ保存

```bash
python scripts/conversation_db.py save \
  --session-id "sess_$(date +%Y%m%d_%H%M%S)" \
  --role "user" \
  --content "ユーザーの入力内容"
```

メタデータ付き:
```bash
python scripts/conversation_db.py save \
  --session-id "$SESSION_ID" \
  --role "assistant" \
  --content "Agentの応答" \
  --model "claude-opus-4" \
  --tokens 500 \
  --tools '["Read", "Write", "Bash"]'
```

### 会話履歴表示

```bash
python scripts/conversation_db.py list --session-id "$SESSION_ID"
```

### セッション一覧

```bash
python scripts/conversation_db.py sessions
```

### 検索

```bash
python scripts/conversation_db.py search --query "エラー"
```

### エクスポート

JSON形式:
```bash
python scripts/conversation_db.py export --session-id "$SESSION_ID" --format json
```

Markdown形式:
```bash
python scripts/conversation_db.py export --session-id "$SESSION_ID" --format markdown
```

## ワークフロー

### 明示的保存（ユーザーリクエスト時）

1. セッションIDを生成: `sess_YYYYMMDD_HHMMSS`
2. ユーザー入力を保存（role: user）
3. Agent応答を保存（role: assistant, ツール情報含む）
4. 保存完了を報告

### 自動保存（重要な会話時）

以下の場合に自動保存を検討:
- エラーが発生した会話
- 複雑なデバッグセッション
- 重要な意思決定を含む会話

### セッション終了時保存

1. 会話全体を収集
2. 各メッセージを順番に保存
3. エクスポートファイルを生成（オプション）

## 注意事項

- 機密情報を含む会話は保存前に確認
- 大量のメッセージはバッチ処理で保存
- データベースは定期的にバックアップ推奨
