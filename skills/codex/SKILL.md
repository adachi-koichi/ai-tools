---
name: codex
description: OpenAI Codex CLIを非インタラクティブモードで実行し、コード生成・編集・レビューなどのタスクを委譲する。ユーザーがCodexにタスクを実行させたいとき、別のAIエージェントの力を借りたいとき、Codexを使いたいと言ったとき、または複雑なコーディングタスクを並列で処理したいときに使用する。
---

# Codex CLI

Codex CLIを`codex exec`コマンドで非インタラクティブに実行する。

## 基本コマンド

```bash
# 基本形式
codex exec -s workspace-write "プロンプト"

# フルオートモード（推奨）
codex exec --full-auto "プロンプト"

# 作業ディレクトリ指定
codex exec --full-auto -C /path/to/dir "プロンプト"

# JSONL形式で出力（パース用）
codex exec --full-auto --json "プロンプト"

# 最終メッセージをファイルに出力
codex exec --full-auto -o result.txt "プロンプト"
```

## サンドボックスモード

| モード | 説明 |
|--------|------|
| `workspace-write` | ワークスペースへの書き込み許可（デフォルト推奨） |
| `read-only` | 読み取り専用 |
| `danger-full-access` | フルアクセス（危険） |

## コードレビュー

```bash
# 現在のリポジトリをレビュー
codex review

# diffを指定してレビュー
codex review --diff-target main
```

## ワークフロー

1. ユーザーからCodexへのタスク依頼を受ける
2. `codex exec --full-auto "タスク内容"` を実行
3. 出力を確認し、必要に応じて結果をユーザーに報告
4. Codexからの質問や確認事項があれば:
   - 自分で判断できる場合: 適切に対応
   - 判断できない場合: AskUserQuestionツールでユーザーに確認

## 出力のハンドリング

`--json`オプションで構造化出力を取得可能:

```bash
codex exec --full-auto --json "タスク" 2>&1
```

出力はJSONL形式で、各行がイベントを表す。

## 注意事項

- 長時間実行されるタスクは`timeout`パラメータを適切に設定
- Git未管理ディレクトリでは`--skip-git-repo-check`を追加
- 複数ディレクトリへの書き込みが必要な場合は`--add-dir`を使用
