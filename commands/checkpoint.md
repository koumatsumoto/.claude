# チェックポイントコマンド

ワークフローのチェックポイントを作成・検証する。

## 使い方

`/checkpoint [create|verify|list] [name]`

## チェックポイント作成

作成時:

1. `/verify quick` を実行して現在状態がクリーンか確認
2. チェックポイント名で git stash か commit を作成
3. `.claude/checkpoints.log` に記録:

```bash
echo "$(date +%Y-%m-%d-%H:%M) | $CHECKPOINT_NAME | \\
$(git rev-parse --short HEAD)" >> .claude/checkpoints.log
```

1. 作成完了を報告

## チェックポイント検証

検証時:

1. ログからチェックポイントを読む
2. 現在状態と比較:
   - チェックポイント以降に追加されたファイル
   - チェックポイント以降に変更されたファイル
   - その時点と比較したテストの合格数
   - その時点と比較したカバレッジ

3. レポート:

```text
CHECKPOINT COMPARISON: $NAME
============================
Files changed: X
Tests: +Y passed / -Z failed
Coverage: +X% / -Y%
Build: [PASS/FAIL]
```

## チェックポイント一覧

以下を表示:

- 名前
- タイムスタンプ
- Git SHA
- ステータス（current / behind / ahead）

## ワークフロー

典型的なチェックポイントフロー:

```text
[Start] --> /checkpoint create "feature-start"
   |
[Implement] --> /checkpoint create "core-done"
   |
[Test] --> /checkpoint verify "core-done"
   |
[Refactor] --> /checkpoint create "refactor-done"
   |
[PR] --> /checkpoint verify "feature-start"
```

## 引数

$ARGUMENTS:

- `create <name>` - 名前付きチェックポイントを作成
- `verify <name>` - 指定チェックポイントで検証
- `list` - チェックポイントを一覧表示
- `clear` - 古いチェックポイント削除（最新 5 件は保持）
