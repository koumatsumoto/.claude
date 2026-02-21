# agent-config

Claude Code と OpenAI Codex CLI の設定を同じリポジトリで管理するための構成です。

## 対応CLI

- Claude Code
- OpenAI Codex CLI

## 運用ポリシー

- **編集元は Claude-first**: このリポジトリ内の `CLAUDE.md` / `agents/` / `rules/` / `skills/` を編集する
- Codex 側の `~/.codex/AGENTS.md` は反映先。**直接編集しない**
- 二重管理を避けるため、インストール時はリンク優先（必要ならコピーへフォールバック）

## ディレクトリ構造

- `CLAUDE.md` - 共通エージェント方針（Claude と Codex AGENTS で共用）
- `agents/` - Claude 用エージェント定義
- `rules/` - ルール定義
- `skills/` - スキル定義（スラッシュコマンド + 参照スキル。Claude / Codex で共用）
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
| `rules/` | `~/.claude/rules/` |
| `skills/` | `~/.claude/skills/` |
| `CLAUDE.md` | `~/.codex/AGENTS.md` |
| `config.toml` | `~/.codex/config.toml` |
| `skills/` | `~/.agents/skills/` |

## 公式仕様（参照元）

- Claude Code
  - Skills: `https://code.claude.com/docs/en/skills`
  - Sub-agents: `https://code.claude.com/docs/en/sub-agents`
  - Memory (`CLAUDE.md`): `https://code.claude.com/docs/en/memory`
  - Settings: `https://code.claude.com/docs/en/settings`
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

### スラッシュコマンド（`disable-model-invocation: true`）

| スキル | 説明 |
| --- | --- |
| `plan` | 実装計画の作成。planner エージェントを起動 |
| `tdd` | テスト駆動開発ワークフロー。tdd-guide エージェントを起動 |
| `code-review` | セキュリティ/品質レビュー |
| `build-fix` | TypeScript/ビルドエラーの段階的修正 |
| `test-coverage` | テストカバレッジ分析と不足テスト生成 |
| `refactor-clean` | デッドコード特定・安全な削除 |
| `orchestrate` | エージェント逐次ワークフロー |
| `learn` | セッションから再利用可能パターンを抽出 |
| `commit` | Conventional Commits 形式で git commit |

### 参照スキル（Claude が自動適用）

| スキル | 説明 |
| --- | --- |
| `coding-standards` | TypeScript/JavaScript コーディング規約 |
| `security-review` | セキュリティレビューチェックリスト |
| `continuous-learning` | パターン抽出と学習 |
| `strategic-compact` | 戦略的コンテキスト圧縮 |

## ライセンス

MIT License。詳細は `LICENSE` を参照。
