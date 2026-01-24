# Git ワークフロー

## コミットメッセージ形式

```text
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

注: ~/.claude/settings.json で Attribution はグローバルに無効化されています。

## Pull Request ワークフロー

PR 作成時:

1. 全コミット履歴を分析（最新コミットだけでなく）
2. `git diff [base-branch]...HEAD` で全変更を確認
3. 包括的な PR サマリを作成
4. TODO 付きのテスト計画を含める
5. 新規ブランチなら `-u` フラグ付きで push

## 機能実装ワークフロー

1. **まず計画**
   - **planner** エージェントで実装計画を作成
   - 依存関係とリスクを特定
   - フェーズに分解

2. **TDD アプローチ**
   - **tdd-guide** エージェントを使用
   - テストを先に書く（RED）
   - テストが通るように実装（GREEN）
   - リファクタリング（IMPROVE）
   - 80%+ カバレッジを検証

3. **コードレビュー**
   - コードを書いた直後に **code-reviewer** エージェントを使用
   - CRITICAL / HIGH を解消
   - 可能な限り MEDIUM も修正

4. **コミット & プッシュ**
   - 詳細なコミットメッセージ
   - Conventional Commits 形式を順守
