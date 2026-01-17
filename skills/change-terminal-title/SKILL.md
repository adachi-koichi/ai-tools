---
name: change-terminal-title
description: Changes terminal or tmux window title. Use when starting agent tasks, switching contexts, organizing terminal windows, or when the user wants to identify terminal tabs. Supports both tmux sessions (SSH) and local terminals.
allowed-tools: Bash, Read
---

# Change Terminal Title

ターミナルペインやtmuxウィンドウのタイトルを変更するスキル。タスク開始時やコンテキスト切り替え時に、ターミナルを識別しやすくする。

## Quick Start

```bash
change-terminal-title.sh "タイトル名"
```

## Use Cases

| シチュエーション | タイトル例 |
|----------------|-----------|
| タスク開始時 | `change-terminal-title.sh "Task: フロントエンド修正"` |
| 環境別作業 | `change-terminal-title.sh "DEV: API Server"` |
| 複数サーバー作業 | `change-terminal-title.sh "prod-db"` |

## How It Works

- **tmux内**: `tmux rename-window` でウィンドウ名を変更
- **ローカルターミナル**: ANSIエスケープシーケンス `\033]0;...\007` でタイトル変更

## Examples

```bash
# 機能開発タスク
change-terminal-title.sh "Feature: ユーザー認証"

# バグ修正
change-terminal-title.sh "Fix: ログイン不具合"

# サーバー監視
change-terminal-title.sh "Logs: Backend"

# ビルド作業
change-terminal-title.sh "Build: Frontend"
```

## Agent Guidelines

1. **タスク開始時**: `change-terminal-title.sh` でターミナルタイトルを設定
2. **タイトル形式**: `[種別]: [概要]` 形式を推奨（例: `Task: 機能名`）
3. **日本語OK**: タイトルに日本語を使用可能