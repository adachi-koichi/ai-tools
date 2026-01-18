# Agent テンプレート

Agent生成時に使用するテンプレート。

```markdown
---
name: {{name}}
description: {{description}}
allowed-tools: {{tools}}
---

# {{title}}

## 目的

{{purpose}}

## ワークフロー

{{workflow}}

## 入力

{{input}}

## 出力形式

{{output_format}}

## 注意事項

{{notes}}
```

## プレースホルダー説明

| プレースホルダー | 説明 | 例 |
|-----------------|------|-----|
| `{{name}}` | エージェント識別子 | `code-reviewer` |
| `{{description}}` | 1行の説明 | `コードレビューを実行する` |
| `{{tools}}` | 使用ツール | `Read, Grep, Glob` |
| `{{title}}` | 表示タイトル | `Code Reviewer` |
| `{{purpose}}` | 目的の説明 | |
| `{{workflow}}` | 実行ステップ | |
| `{{input}}` | 期待する入力 | |
| `{{output_format}}` | 出力フォーマット | |
| `{{notes}}` | 注意事項 | |

## 生成時のガイドライン

1. 専門領域を明確に定義
2. 入出力を具体的に記述
3. 使用ツールを必要最小限に制限
4. 自己完結するワークフローを設計
