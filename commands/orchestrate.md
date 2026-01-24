# オーケストレーションコマンド

複雑なタスク向けの、エージェント逐次ワークフロー。

## 使い方

`/orchestrate [workflow-type] [task-description]`

## ワークフロー種別

### feature

フル機能実装ワークフロー:

```text
planner -> tdd-guide -> code-reviewer -> security-reviewer
```

### bugfix

バグ調査と修正ワークフロー:

```text
explorer -> tdd-guide -> code-reviewer
```

### refactor

安全なリファクタリングワークフロー:

```text
architect -> code-reviewer -> tdd-guide
```

### security

セキュリティ重視レビュー:

```text
security-reviewer -> code-reviewer -> architect
```

## 実行パターン

ワークフロー内の各エージェントについて:

1. **エージェントを起動**（前エージェントの文脈を渡す）
2. **出力を収集**して引き継ぎ文書を作成
3. **次のエージェントへ引き継ぐ**
4. **結果を集約**し最終レポートを生成

## 引き継ぎ文書の形式

エージェント間で以下の文書を作成:

```markdown
## HANDOFF: [previous-agent] -> [next-agent]

### Context

[Summary of what was done]

### Findings

[Key discoveries or decisions]

### Files Modified

[List of files touched]

### Open Questions

[Unresolved items for next agent]

### Recommendations

[Suggested next steps]
```

## 例: feature ワークフロー

```text
/orchestrate feature "Add user authentication"
```

実行内容:

1. **Planner エージェント**
   - 要件分析
   - 実装計画作成
   - 依存関係の特定
   - 出力: `HANDOFF: planner -> tdd-guide`

2. **TDD Guide エージェント**
   - planner の引き継ぎを読む
   - テストを先に書く
   - テストが通る実装
   - 出力: `HANDOFF: tdd-guide -> code-reviewer`

3. **Code Reviewer エージェント**
   - 実装のレビュー
   - 問題点チェック
   - 改善提案
   - 出力: `HANDOFF: code-reviewer -> security-reviewer`

4. **Security Reviewer エージェント**
   - セキュリティ監査
   - 脆弱性確認
   - 最終承認
   - 出力: 最終レポート

## 最終レポート形式

```text
ORCHESTRATION REPORT
====================
Workflow: feature
Task: Add user authentication
Agents: planner -> tdd-guide -> code-reviewer -> security-reviewer

SUMMARY
-------
[One paragraph summary]

AGENT OUTPUTS
-------------
Planner: [summary]
TDD Guide: [summary]
Code Reviewer: [summary]
Security Reviewer: [summary]

FILES CHANGED
-------------
[List all files modified]

TEST RESULTS
------------
[Test pass/fail summary]

SECURITY STATUS
---------------
[Security findings]

RECOMMENDATION
--------------
[SHIP / NEEDS WORK / BLOCKED]
```

## 並列実行

独立チェックは並列で実行:

```markdown
### Parallel Phase

Run simultaneously:

- code-reviewer (quality)
- security-reviewer (security)
- architect (design)

### Merge Results

Combine outputs into single report
```

## 引数

$ARGUMENTS:

- `feature <description>` - フル機能ワークフロー
- `bugfix <description>` - バグ修正ワークフロー
- `refactor <description>` - リファクタリング
- `security <description>` - セキュリティレビュー
- `custom <agents> <description>` - カスタムエージェント列

## カスタムワークフロー例

```text
/orchestrate custom "architect,tdd-guide,code-reviewer" "Redesign caching layer"
```

## ヒント

1. 複雑な機能は **planner** から開始
2. マージ前に **code-reviewer** を必ず含める
3. 認証/決済/PII は **security-reviewer** を使う
4. 引き継ぎは簡潔に - 次のエージェントに必要な情報だけ
5. エージェント間で必要なら検証を挟む
