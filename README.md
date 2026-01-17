# ai-tools

## スキルのインストール

### 基本的な使い方

```bash
# スキル名を指定してインストール（カレントディレクトリの .cursor, .codex, .claude を自動検出）
curl -sSL https://raw.githubusercontent.com/adachi-koichi/ai-tools/main/skills/install.sh | bash -s <skill_name>
```

### インストール先の指定

```bash
# ホームディレクトリにインストール（~/.claude, ~/.codex, ~/.cursor）
curl -sSL https://raw.githubusercontent.com/adachi-koichi/ai-tools/main/skills/install.sh | bash -s <skill_name> ~

# カレントディレクトリにインストール（./claude, ./codex, ./cursor）
curl -sSL https://raw.githubusercontent.com/adachi-koichi/ai-tools/main/skills/install.sh | bash -s <skill_name> .
```

### 使用例

```bash
# miroスキルをインストール（自動検出）
curl -sSL https://raw.githubusercontent.com/adachi-koichi/ai-tools/main/skills/install.sh | bash -s miro

# change-terminal-titleスキルをホームディレクトリにインストール
curl -sSL https://raw.githubusercontent.com/adachi-koichi/ai-tools/main/skills/install.sh | bash -s change-terminal-title ~

# miroスキルをカレントディレクトリにインストール
curl -sSL https://raw.githubusercontent.com/adachi-koichi/ai-tools/main/skills/install.sh | bash -s miro .
```

## 利用可能なスキル

- `miro`: Miro APIを使用するスキル
- `change-terminal-title`: ターミナルのタイトルを変更するスキル