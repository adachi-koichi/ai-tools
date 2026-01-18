#!/usr/bin/env python3
"""
Agent会話ログをSQLiteに保存・管理するスクリプト

使用方法:
  # 会話を保存
  python conversation_db.py save --session-id "sess_123" --role "user" --content "Hello"

  # メタデータ付きで保存
  python conversation_db.py save --session-id "sess_123" --role "assistant" --content "Hi!" \
    --model "claude-opus-4" --tokens 150 --tools '["Read", "Write"]'

  # 会話履歴を表示
  python conversation_db.py list --session-id "sess_123"

  # すべてのセッションを表示
  python conversation_db.py sessions

  # 検索
  python conversation_db.py search --query "error"

  # エクスポート
  python conversation_db.py export --session-id "sess_123" --format json
"""

import argparse
import json
import sqlite3
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional

# スクリプトの親ディレクトリ（スキルフォルダ）にDBを作成
SKILL_DIR = Path(__file__).resolve().parent.parent
DEFAULT_DB_PATH = SKILL_DIR / "conversations.db"


def get_db_connection(db_path: Path) -> sqlite3.Connection:
    """データベース接続を取得し、必要に応じてテーブルを作成"""
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(db_path))
    conn.row_factory = sqlite3.Row

    conn.executescript("""
        CREATE TABLE IF NOT EXISTS sessions (
            id TEXT PRIMARY KEY,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            metadata TEXT
        );

        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            model TEXT,
            token_count INTEGER,
            tools_used TEXT,
            error_info TEXT,
            metadata TEXT,
            FOREIGN KEY (session_id) REFERENCES sessions(id)
        );

        CREATE INDEX IF NOT EXISTS idx_messages_session ON messages(session_id);
        CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp);
        CREATE INDEX IF NOT EXISTS idx_messages_role ON messages(role);
    """)

    return conn


def save_message(
    conn: sqlite3.Connection,
    session_id: str,
    role: str,
    content: str,
    model: Optional[str] = None,
    token_count: Optional[int] = None,
    tools_used: Optional[list] = None,
    error_info: Optional[str] = None,
    metadata: Optional[dict] = None
) -> int:
    """メッセージを保存"""
    now = datetime.now().isoformat()

    # セッションが存在しなければ作成
    conn.execute("""
        INSERT INTO sessions (id, created_at, updated_at, metadata)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET updated_at = ?
    """, (session_id, now, now, None, now))

    cursor = conn.execute("""
        INSERT INTO messages (session_id, role, content, timestamp, model, token_count, tools_used, error_info, metadata)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        session_id,
        role,
        content,
        now,
        model,
        token_count,
        json.dumps(tools_used) if tools_used else None,
        error_info,
        json.dumps(metadata) if metadata else None
    ))

    conn.commit()
    return cursor.lastrowid


def list_messages(conn: sqlite3.Connection, session_id: str, limit: int = 100) -> list:
    """セッションのメッセージ一覧を取得"""
    cursor = conn.execute("""
        SELECT * FROM messages
        WHERE session_id = ?
        ORDER BY timestamp ASC
        LIMIT ?
    """, (session_id, limit))
    return [dict(row) for row in cursor.fetchall()]


def list_sessions(conn: sqlite3.Connection, limit: int = 50) -> list:
    """セッション一覧を取得"""
    cursor = conn.execute("""
        SELECT s.*, COUNT(m.id) as message_count
        FROM sessions s
        LEFT JOIN messages m ON s.id = m.session_id
        GROUP BY s.id
        ORDER BY s.updated_at DESC
        LIMIT ?
    """, (limit,))
    return [dict(row) for row in cursor.fetchall()]


def search_messages(conn: sqlite3.Connection, query: str, limit: int = 50) -> list:
    """メッセージを検索"""
    cursor = conn.execute("""
        SELECT * FROM messages
        WHERE content LIKE ?
        ORDER BY timestamp DESC
        LIMIT ?
    """, (f"%{query}%", limit))
    return [dict(row) for row in cursor.fetchall()]


def export_session(conn: sqlite3.Connection, session_id: str, format: str = "json") -> str:
    """セッションをエクスポート"""
    messages = list_messages(conn, session_id, limit=10000)

    if format == "json":
        return json.dumps(messages, indent=2, ensure_ascii=False)
    elif format == "markdown":
        lines = [f"# Session: {session_id}\n"]
        for msg in messages:
            role = msg["role"].upper()
            content = msg["content"]
            timestamp = msg["timestamp"]
            lines.append(f"## [{role}] {timestamp}\n\n{content}\n")
        return "\n".join(lines)
    else:
        raise ValueError(f"Unknown format: {format}")


def main():
    parser = argparse.ArgumentParser(description="Agent会話ログ管理")
    parser.add_argument("--db", type=Path, default=DEFAULT_DB_PATH, help="データベースファイルのパス")

    subparsers = parser.add_subparsers(dest="command", required=True)

    # save コマンド
    save_parser = subparsers.add_parser("save", help="メッセージを保存")
    save_parser.add_argument("--session-id", required=True, help="セッションID")
    save_parser.add_argument("--role", required=True, choices=["user", "assistant", "system"], help="ロール")
    save_parser.add_argument("--content", required=True, help="メッセージ内容")
    save_parser.add_argument("--model", help="モデル名")
    save_parser.add_argument("--tokens", type=int, help="トークン数")
    save_parser.add_argument("--tools", help="使用したツール (JSON配列)")
    save_parser.add_argument("--error", help="エラー情報")
    save_parser.add_argument("--metadata", help="メタデータ (JSON)")

    # list コマンド
    list_parser = subparsers.add_parser("list", help="メッセージ一覧を表示")
    list_parser.add_argument("--session-id", required=True, help="セッションID")
    list_parser.add_argument("--limit", type=int, default=100, help="取得件数")

    # sessions コマンド
    sessions_parser = subparsers.add_parser("sessions", help="セッション一覧を表示")
    sessions_parser.add_argument("--limit", type=int, default=50, help="取得件数")

    # search コマンド
    search_parser = subparsers.add_parser("search", help="メッセージを検索")
    search_parser.add_argument("--query", required=True, help="検索クエリ")
    search_parser.add_argument("--limit", type=int, default=50, help="取得件数")

    # export コマンド
    export_parser = subparsers.add_parser("export", help="セッションをエクスポート")
    export_parser.add_argument("--session-id", required=True, help="セッションID")
    export_parser.add_argument("--format", choices=["json", "markdown"], default="json", help="出力形式")

    args = parser.parse_args()
    conn = get_db_connection(args.db)

    try:
        if args.command == "save":
            tools = json.loads(args.tools) if args.tools else None
            metadata = json.loads(args.metadata) if args.metadata else None
            msg_id = save_message(
                conn, args.session_id, args.role, args.content,
                args.model, args.tokens, tools, args.error, metadata
            )
            print(json.dumps({"status": "ok", "message_id": msg_id}))

        elif args.command == "list":
            messages = list_messages(conn, args.session_id, args.limit)
            print(json.dumps(messages, indent=2, ensure_ascii=False))

        elif args.command == "sessions":
            sessions = list_sessions(conn, args.limit)
            print(json.dumps(sessions, indent=2, ensure_ascii=False))

        elif args.command == "search":
            messages = search_messages(conn, args.query, args.limit)
            print(json.dumps(messages, indent=2, ensure_ascii=False))

        elif args.command == "export":
            output = export_session(conn, args.session_id, args.format)
            print(output)

    finally:
        conn.close()


if __name__ == "__main__":
    main()
