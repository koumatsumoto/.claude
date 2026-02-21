---
name: orchestrate
description: 複雑なタスク向けのエージェント逐次ワークフロー。feature/bugfix/refactor/security/custom から選択。
disable-model-invocation: true
argument-hint: "[workflow-type] [task-description]"
---

# Orchestrate

複雑なタスク向けの、エージェント逐次ワークフロー。

## 使い方

`/orchestrate $ARGUMENTS`

## ワークフロー種別

### feature

フル機能実装ワークフロー:

```text
planner -> tdd-guide -> code-reviewer -> security-reviewer
```

### bugfix

バグ調査と修正ワークフロー:

```text
build-error-resolver -> tdd-guide -> code-reviewer
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

### custom

カスタムエージェント列:

```text
/orchestrate custom "architect,tdd-guide,code-reviewer" "Redesign caching layer"
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

## 最終レポート形式

```text
ORCHESTRATION REPORT
====================
Workflow: [type]
Task: [description]
Agents: [agent chain]

SUMMARY
-------
[One paragraph summary]

AGENT OUTPUTS
-------------
[Each agent's summary]

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

## ヒント

1. 複雑な機能は **planner** から開始
2. マージ前に **code-reviewer** を必ず含める
3. 認証/決済/PII は **security-reviewer** を使う
4. 引き継ぎは簡潔に - 次のエージェントに必要な情報だけ
5. エージェント間で必要なら検証を挟む
