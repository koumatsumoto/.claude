# Eval コマンド

Eval 駆動開発ワークフローを管理する。

## 使い方

`/eval [define|check|report|list] [feature-name]`

## Eval を定義

`/eval define feature-name`

新しい eval 定義を作成:

1. `.claude/evals/feature-name.md` をテンプレートで作成:

```markdown
## EVAL: feature-name

Created: $(date)

### Capability Evals

- [ ] [Description of capability 1]
- [ ] [Description of capability 2]

### Regression Evals

- [ ] [Existing behavior 1 still works]
- [ ] [Existing behavior 2 still works]

### Success Criteria

- pass@3 > 90% for capability evals
- pass^3 = 100% for regression evals
```

1. ユーザーに具体的な基準を埋めてもらう

## Eval をチェック

`/eval check feature-name`

機能に対して eval を実行:

1. `.claude/evals/feature-name.md` の定義を読む
2. 各 capability eval について:
   - 基準を検証
   - PASS/FAIL を記録
   - `.claude/evals/feature-name.log` に試行を記録
3. 各 regression eval について:
   - 該当テストを実行
   - ベースラインと比較
   - PASS/FAIL を記録
4. 現在状態をレポート:

```text
EVAL CHECK: feature-name
========================
Capability: X/Y passing
Regression: X/Y passing
Status: IN PROGRESS / READY
```

## Eval をレポート

`/eval report feature-name`

包括的な eval レポートを生成:

```text
EVAL REPORT: feature-name
=========================
Generated: $(date)

CAPABILITY EVALS
----------------
[eval-1]: PASS (pass@1)
[eval-2]: PASS (pass@2) - required retry
[eval-3]: FAIL - see notes

REGRESSION EVALS
----------------
[test-1]: PASS
[test-2]: PASS
[test-3]: PASS

METRICS
-------
Capability pass@1: 67%
Capability pass@3: 100%
Regression pass^3: 100%

NOTES
-----
[Any issues, edge cases, or observations]

RECOMMENDATION
--------------
[SHIP / NEEDS WORK / BLOCKED]
```

## Eval 一覧

`/eval list`

全ての eval 定義を表示:

```text
EVAL DEFINITIONS
================
feature-auth      [3/5 passing] IN PROGRESS
feature-search    [5/5 passing] READY
feature-export    [0/4 passing] NOT STARTED
```

## 引数

$ARGUMENTS:

- `define <name>` - 新しい eval 定義を作成
- `check <name>` - eval を実行してチェック
- `report <name>` - 詳細レポートを生成
- `list` - eval 一覧を表示
- `clean` - 古い eval ログを削除（最新 10 件は保持）
