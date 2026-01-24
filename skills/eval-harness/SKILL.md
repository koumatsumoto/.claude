# Eval ハーネススキル

Claude Code セッション向けの形式的な評価フレームワーク。Eval-Driven Development（EDD）の原則を実装する。

## 哲学

Eval-Driven Development は eval を「AI 開発のユニットテスト」として扱う:

- 実装前に期待される挙動を定義
- 開発中に継続的に eval を実行
- 変更ごとに回帰を追跡
- pass@k 指標で信頼性を測定

## Eval の種類

### Capability Evals

Claude が新しくできるようになったことを検証:

```markdown
[CAPABILITY EVAL: feature-name]
Task: Description of what Claude should accomplish
Success Criteria:

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
      Expected Output: Description of expected result
```

### Regression Evals

既存機能の破壊がないかを検証:

```markdown
[REGRESSION EVAL: feature-name]
Baseline: SHA or checkpoint name
Tests:

- existing-test-1: PASS/FAIL
- existing-test-2: PASS/FAIL
- existing-test-3: PASS/FAIL
  Result: X/Y passed (previously Y/Y)
```

## グレーダー種別

### 1. コードベースのグレーダー

コードで決定的にチェック:

```bash
# ファイルに期待パターンがあるか
grep -q "export function handleAuth" src/auth.ts && echo "PASS" || echo "FAIL"

# テストが通るか
npm test -- --testPathPattern="auth" && echo "PASS" || echo "FAIL"

# ビルドが成功するか
npm run build && echo "PASS" || echo "FAIL"
```

### 2. モデルベースのグレーダー

Claude でオープンエンド出力を評価:

```markdown
[MODEL GRADER PROMPT]
Evaluate the following code change:

1. Does it solve the stated problem?
2. Is it well-structured?
3. Are edge cases handled?
4. Is error handling appropriate?

Score: 1-5 (1=poor, 5=excellent)
Reasoning: [explanation]
```

### 3. 人間グレーダー

手動レビュー用にフラグ:

```markdown
[HUMAN REVIEW REQUIRED]
Change: Description of what changed
Reason: Why human review is needed
Risk Level: LOW/MEDIUM/HIGH
```

## 指標

### pass@k

「k 回以内に 1 回でも成功」

- pass@1: 1 回目成功率
- pass@3: 3 回以内成功率
- 目標: pass@3 > 90%

### pass^k

「k 回連続成功」

- より厳しい指標
- pass^3: 3 回連続成功
- 重要経路に使用

## Eval ワークフロー

### 1. 定義（実装前）

```markdown
## EVAL DEFINITION: feature-xyz

### Capability Evals

1. Can create new user account
2. Can validate email format
3. Can hash password securely

### Regression Evals

1. Existing login still works
2. Session management unchanged
3. Logout flow intact

### Success Metrics

- pass@3 > 90% for capability evals
- pass^3 = 100% for regression evals
```

### 2. 実装

定義した eval を満たすコードを書く。

### 3. 評価

```bash
# capability eval を実行
[Run each capability eval, record PASS/FAIL]

# regression eval を実行
npm test -- --testPathPattern="existing"

# レポート生成
```

### 4. レポート

```markdown
# EVAL REPORT: feature-xyz

Capability Evals:
create-user: PASS (pass@1)
validate-email: PASS (pass@2)
hash-password: PASS (pass@1)
Overall: 3/3 passed

Regression Evals:
login-flow: PASS
session-mgmt: PASS
logout-flow: PASS
Overall: 3/3 passed

Metrics:
pass@1: 67% (2/3)
pass@3: 100% (3/3)

Status: READY FOR REVIEW
```

## 連携パターン

### 実装前

```text
/eval define feature-name
```

`.claude/evals/feature-name.md` に定義を作成

### 実装中

```text
/eval check feature-name
```

現在の eval を実行して状況を報告

### 実装後

```text
/eval report feature-name
```

詳細レポートを生成

## Eval の保存場所

プロジェクト内に保存:

```text
.claude/
  evals/
    feature-xyz.md      # Eval 定義
    feature-xyz.log     # 実行履歴
    baseline.json       # 回帰ベースライン
```

## ベストプラクティス

1. **実装前に定義** - 成功基準を明確化
2. **頻繁に実行** - 回帰の早期発見
3. **pass@k の推移を追跡** - 信頼性の傾向管理
4. **コードグレーダーを優先** - 決定的 > 確率的
5. **セキュリティは人間レビュー** - 自動化しない
6. **高速に保つ** - 遅い eval は回らない
7. **コードと同時にバージョン管理** - eval も成果物

## 例: 認証追加

```markdown
## EVAL: add-authentication

### Phase 1: Define (10 min)

Capability Evals:

- [ ] User can register with email/password
- [ ] User can login with valid credentials
- [ ] Invalid credentials rejected with proper error
- [ ] Sessions persist across page reloads
- [ ] Logout clears session

Regression Evals:

- [ ] Public routes still accessible
- [ ] API responses unchanged
- [ ] Database schema compatible

### Phase 2: Implement (varies)

[Write code]

### Phase 3: Evaluate

Run: /eval check add-authentication

### Phase 4: Report

# EVAL REPORT: add-authentication

Capability: 5/5 passed (pass@3: 100%)
Regression: 3/3 passed (pass^3: 100%)
Status: SHIP IT
```
