# 検証ループスキル

Claude Code セッション向けの包括的な検証システム。

## 使うタイミング

このスキルを呼び出す:

- 機能や大きな変更の完了後
- PR 作成前
- 品質ゲートを確認したい時
- リファクタ後

## 検証フェーズ

### Phase 1: ビルド検証

```bash
# プロジェクトがビルドできるか
npm run build 2>&1 | tail -20
# OR
pnpm build 2>&1 | tail -20
```

ビルドが失敗したら、止めて修正してから続行。

### Phase 2: 型チェック

```bash
# TypeScript プロジェクト
npx tsc --noEmit 2>&1 | head -30

# Python プロジェクト
pyright . 2>&1 | head -30
```

型エラーは全て報告し、重要なものは修正してから続行。

### Phase 3: Lint チェック

```bash
# JavaScript/TypeScript
npm run lint 2>&1 | head -30

# Python
ruff check . 2>&1 | head -30
```

### Phase 4: テストスイート

```bash
# カバレッジ付きでテスト
npm run test -- --coverage 2>&1 | tail -50

# カバレッジ閾値
# 目標: 最低 80%
```

報告項目:

- 総テスト数: X
- 合格: X
- 失敗: X
- カバレッジ: X%

### Phase 5: セキュリティスキャン

```bash
# シークレット検出
grep -rn "sk-" --include="*.ts" --include="*.js" . 2>/dev/null | head -10
grep -rn "api_key" --include="*.ts" --include="*.js" . 2>/dev/null | head -10

# console.log 検出
grep -rn "console.log" \
  --include="*.ts" \
  --include="*.tsx" \
  src/ 2>/dev/null | head -10
```

### Phase 6: 差分レビュー

```bash
# 変更内容を確認
git diff --stat
git diff HEAD~1 --name-only
```

変更ファイルごとに確認:

- 意図しない変更がないか
- エラーハンドリングが不足していないか
- エッジケースが抜けていないか

## 出力形式

全フェーズ後、検証レポートを出力:

```text
VERIFICATION REPORT
==================

Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR

Issues to Fix:
1. ...
2. ...
```

## 継続モード

長いセッションでは、15 分ごと or 主要変更ごとに検証:

```markdown
Set a mental checkpoint:

- After completing each function
- After finishing a component
- Before moving to next task

Run: /verify
```

## フックとの連携

このスキルは PostToolUse フックを補完する。フックは即時検知、こちらは包括的レビュー。
