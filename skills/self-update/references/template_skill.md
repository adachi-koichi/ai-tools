# Skill テンプレート

Skill生成時に使用するテンプレート。

```markdown
---
name: {{name}}
description: {{description}}
---

# {{title}}

{{overview}}

## 機能

{{features}}

## ワークフロー

{{workflow}}

## 関連リソース

{{resources}}

## 使用例

{{examples}}

## 注意事項

{{notes}}
```

## プレースホルダー説明

| プレースホルダー | 説明 | 例 |
|-----------------|------|-----|
| `{{name}}` | スキル識別子 | `miro-api` |
| `{{description}}` | 詳細な説明（トリガー条件含む） | |
| `{{title}}` | 表示タイトル | `Miro API Integration` |
| `{{overview}}` | 概要 | |
| `{{features}}` | 機能リスト | |
| `{{workflow}}` | 使用手順 | |
| `{{resources}}` | 関連ファイルへのリンク | |
| `{{examples}}` | 使用例 | |
| `{{notes}}` | 注意事項 | |

## 生成時のガイドライン

1. descriptionにトリガー条件を明記
2. Progressive Disclosureを意識
3. 関連リソースは別ファイルに分離
4. 500行以内を目標
