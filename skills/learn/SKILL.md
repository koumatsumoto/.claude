---
name: learn
description: 現在のセッションを分析し、再利用可能パターンを抽出してスキルとして保存する。
disable-model-invocation: true
---

# Learn

現在のセッションを分析し、スキルとして保存すべきパターンを抽出する。

## トリガー

非自明な問題を解決したタイミングで、セッション中いつでも `/learn` を実行する。

## 抽出対象

以下を探す:

1. **エラー解決パターン**
   - どんなエラーが起きたか
   - 根本原因は何か
   - 何が解決したか
   - 類似エラーに再利用できるか

2. **デバッグ技法**
   - 非自明なデバッグ手順
   - 有効だったツール組み合わせ
   - 診断パターン

3. **回避策**
   - ライブラリの癖
   - API 制約
   - バージョン特有の修正

4. **プロジェクト固有のパターン**
   - 発見したコードベースの慣習
   - 行ったアーキテクチャ判断
   - 連携パターン

## 出力形式

`~/.claude/skills/learned/[pattern-name]/SKILL.md` に作成:

```markdown
---
name: [pattern-name]
description: [When this pattern applies and what it solves]
---

# [Descriptive Pattern Name]

**Extracted:** [Date]
**Context:** [Brief description of when this applies]

## Problem

[What problem this solves - be specific]

## Solution

[The pattern/technique/workaround]

## Example

[Code example if applicable]
```

## 進め方

1. セッションから抽出可能なパターンを洗い出す
2. 最も価値の高い/再利用可能な気づきを選ぶ
3. スキルファイルの下書きを作成
4. 保存前にユーザーへ確認
5. `~/.claude/skills/learned/` に保存

## 注意

- 些細な修正（タイポ、単純な構文ミス）は抽出しない
- 一度きりの問題（特定の API 障害など）は抽出しない
- 将来の時間短縮に繋がるパターンに集中
- 1 スキル 1 パターンに絞る
