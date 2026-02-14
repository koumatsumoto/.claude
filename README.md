# agent-config

Claude Code と OpenAI Codex CLI の設定を同じリポジトリで管理するための構成です。

## 対応CLI

- Claude Code
- OpenAI Codex CLI

## 運用ポリシー

- **編集元は Claude-first**: このリポジトリ内の `CLAUDE.md` / `agents/` / `commands/` / `rules/` / `skills/` を編集する
- Codex 側の `~/.codex/AGENTS.md` は反映先。**直接編集しない**
- 二重管理を避けるため、インストール時はリンク優先（必要ならコピーへフォールバック）

## ディレクトリ構造

- `CLAUDE.md` - 共通エージェント方針（Claude と Codex AGENTS で共用）
- `agents/` - Claude 用エージェント定義
- `commands/` - Claude 用コマンド定義
- `rules/` - ルール定義
- `skills/` - 共通スキル定義（Claude / Codex で共用）
- `config.toml` - Codex CLI 用の最小設定テンプレート
- `install.sh` - `~/` 配下へ反映するインストールスクリプト

## セットアップ

推奨コマンド:

```bash
bash install.sh
```

このコマンドは以下を反映します:

- `~/.claude/`:
  - `CLAUDE.md`
  - `agents/`
  - `commands/`
  - `rules/`
  - `skills/`
- `~/.codex/`:
  - `AGENTS.md`（`CLAUDE.md` から反映）
  - `config.toml`（`config.toml` から反映）
- `~/.agents/`:
  - `skills/`（Codex Skills 用）

`install.sh` は引数なしで、Claude/Codex の両方を一括反映します。

## OS別メモ

- Ubuntu/Linux:
  - 通常は symlink で反映される
- Windows (Git Bash):
  - シンボリックリンク権限が不足する環境では自動でコピーへフォールバック

## 反映先マッピング

| Repository Source | Destination |
| --- | --- |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `agents/` | `~/.claude/agents/` |
| `commands/` | `~/.claude/commands/` |
| `rules/` | `~/.claude/rules/` |
| `skills/` | `~/.claude/skills/` |
| `CLAUDE.md` | `~/.codex/AGENTS.md` |
| `config.toml` | `~/.codex/config.toml` |
| `skills/` | `~/.agents/skills/` |

## 公式仕様（参照元）

- Claude Code
  - Settings: `https://docs.anthropic.com/en/docs/claude-code/settings`
  - Memory (`CLAUDE.md`): `https://docs.anthropic.com/en/docs/claude-code/memory`
  - Slash Commands: `https://docs.anthropic.com/en/docs/claude-code/slash-commands`
  - Sub-agents: `https://docs.anthropic.com/en/docs/claude-code/sub-agents`
- OpenAI Codex CLI
  - Config: `https://developers.openai.com/codex/config`
  - Config Reference: `https://developers.openai.com/codex/config#reference`
  - AGENTS.md: `https://developers.openai.com/codex/customization#agentsmd`
  - Skills: `https://developers.openai.com/codex/customization#skills`
  - CLI Overview: `https://developers.openai.com/codex/cli`

## 既存ファイルの保護

`install.sh` は同名ファイル/ディレクトリが既に存在する場合、  
`*.bak.<timestamp>` へ退避してから置換します。

## スキル一覧

| スキル | 説明 |
| --- | --- |
| `coding-standards` | TypeScript/JavaScript コーディング規約 |
| `security-review` | セキュリティレビューチェックリスト |
| `continuous-learning` | パターン抽出と学習 |
| `strategic-compact` | 戦略的コンテキスト圧縮 |

## ライセンス

MIT License。詳細は `LICENSE` を参照。
