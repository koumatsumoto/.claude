# Claude Code Configuration

Claude Code の再利用可能な設定ファイル集。エージェント、コマンド、ルール、スキルを含みます。

## ディレクトリ構造

- **agents/** - 特化型エージェント（planner, architect, tdd-guide など）
- **commands/** - カスタムコマンド（/plan, /e2e, /code-review など）
- **rules/** - コーディング規約（security, testing, git-workflow など）
- **skills/** - 再利用可能なスキル（tdd-workflow, backend-patterns など）

## 使い方

### 方法1: シンボリックリンク（推奨）

既存の `~/.claude` をバックアップし、このリポジトリをリンク:

```bash
# 既存設定のバックアップ
mv ~/.claude ~/.claude.backup

# このリポジトリをクローン
git clone <repository-url> ~/.claude

# 個人設定を復元（必要に応じて）
cp ~/.claude.backup/.credentials.json ~/.claude/
cp ~/.claude.backup/settings.json ~/.claude/
```

### 方法2: 選択的コピー

必要なファイルのみコピー:

```bash
# エージェントのみ使用
cp -r ./agents ~/.claude/

# すべてコピー
cp -r ./{agents,commands,rules,skills,CLAUDE.md} ~/.claude/
```

### 方法3: Git で管理

`~/.claude` を Git リポジトリとして管理:

```bash
cd ~/.claude
git init
git remote add origin <repository-url>
git pull origin main

# .gitignore で個人情報を除外
```

## カスタマイズ

### CLAUDE.md

`CLAUDE.md` はユーザーレベルのグローバル設定です。
自分のワークフローに合わせて編集してください。

### 個人設定の追加

以下のファイルは `.gitignore` で除外されているため、ローカルで作成できます:

- `.credentials.json` - OAuth トークン
- `settings.json` - ローカルパス、権限設定
- `settings.local.json` - 追加のローカル設定

## エージェント一覧

| エージェント         | 目的                         |
| -------------------- | ---------------------------- |
| planner              | 実装計画                     |
| architect            | システム設計とアーキテクチャ |
| tdd-guide            | テスト駆動開発               |
| code-reviewer        | 品質/セキュリティレビュー    |
| security-reviewer    | 脆弱性分析                   |
| build-error-resolver | ビルドエラー解決             |
| e2e-runner           | Playwright E2E テスト        |
| refactor-cleaner     | デッドコード清掃             |
| doc-updater          | ドキュメント更新             |

## スキル一覧

| スキル              | 説明                                   |
| ------------------- | -------------------------------------- |
| tdd-workflow        | テスト駆動開発ワークフロー             |
| backend-patterns    | バックエンドアーキテクチャパターン     |
| frontend-patterns   | フロントエンド開発パターン             |
| security-review     | セキュリティレビューチェックリスト     |
| coding-standards    | TypeScript/JavaScript コーディング規約 |
| clickhouse-io       | ClickHouse 最適化パターン              |
| continuous-learning | パターン抽出と学習                     |
| strategic-compact   | 戦略的コンテキスト圧縮                 |
| verification-loop   | 検証ループパターン                     |
| eval-harness        | 評価ハーネス                           |
| project-guidelines  | プロジェクトガイドライン例             |

## セキュリティ

このリポジトリには **機密情報は含まれていません**:

- 認証トークンなし
- 個人ログなし
- ローカルパスなし

`.gitignore` により、個人情報が誤ってコミットされることを防ぎます。

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照してください。

## コントリビューション

改善提案は Issue または Pull Request でお願いします。

---

**哲学**: Agent-first 設計、並列実行、行動前の計画、テスト先行、常にセキュリティ。
