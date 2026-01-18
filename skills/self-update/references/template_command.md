# Command テンプレート

Command生成時に使用するテンプレート。

```markdown
---
description: {{description}}
allowed-tools: {{tools}}
argument-hint: {{argument_hint}}
---

# {{title}}

{{overview}}

## 引数

- `$ARGUMENTS`: {{argument_description}}

## ワークフロー

{{workflow}}

## 実行例

{{examples}}
```

## プレースホルダー説明

| プレースホルダー | 説明 | 例 |
|-----------------|------|-----|
| `{{description}}` | 1行の説明 | `安全にgit pullを実行` |
| `{{tools}}` | 使用ツール | `Bash` |
| `{{argument_hint}}` | 引数のヒント | `[branch]` |
| `{{title}}` | コマンド名 | `Git Safe Pull` |
| `{{overview}}` | 概要説明 | |
| `{{argument_description}}` | 引数の説明 | |
| `{{workflow}}` | 実行手順 | |
| `{{examples}}` | 使用例 | |

## 生成時のガイドライン

1. 短く覚えやすい名前
2. 引数は最小限に
3. 1コマンド1目的の原則
4. エラーハンドリングを含める
