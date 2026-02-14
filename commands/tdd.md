---
description: >-
  テスト駆動開発ワークフローを強制する。インターフェースを足場に、まず
  テストを生成し、その後に最小実装で通す。80%+ カバレッジを保証。
---

# TDD コマンド

このコマンドは **tdd-guide** エージェントを起動し、テスト駆動開発手法を徹底する。

## このコマンドが行うこと

1. **インターフェースの足場作り** - 型/インターフェースを先に定義
2. **テストを先に生成** - 失敗するテストを書く（RED）
3. **最小実装** - 通る最小実装を書く（GREEN）
4. **リファクタ** - テストを緑のまま改善（REFACTOR）
5. **カバレッジ検証** - 80%+ を確保

## 使うタイミング

`/tdd` を使うのは:

- 新機能の実装
- 新しい関数/コンポーネント追加
- バグ修正（再現テストを先に書く）
- 既存コードのリファクタ
- 重要なビジネスロジック

## 動作

tdd-guide エージェントは以下を行う:

1. 入出力の **インターフェース定義**
2. **失敗するテスト** を書く（コードがまだ無い）
3. **テスト実行** して失敗を確認
4. **最小実装** でテストを通す
5. **再度テスト** して通過を確認
6. **リファクタ** して品質改善
7. **カバレッジ** を確認し 80% 未満なら追加テスト

## TDD サイクル

```text
RED → GREEN → REFACTOR → REPEAT

RED:      失敗するテストを書く
GREEN:    テストを通す最小実装を書く
REFACTOR: テストを保ったまま改善
REPEAT:   次の機能/シナリオへ
```

## 使用例

````text
User: /tdd I need a function to calculate market liquidity score

Agent (tdd-guide):
# TDD Session: Market Liquidity Score Calculator

## Step 1: Define Interface (SCAFFOLD)

```typescript
// lib/liquidity.ts
export interface MarketData {
  totalVolume: number
  bidAskSpread: number
  activeTraders: number
  lastTradeTime: Date
}

export function calculateLiquidityScore(market: MarketData): number {
  // TODO: Implementation
  throw new Error('Not implemented')
}
````

## Step 2: Write Failing Test (RED)

```typescript
// lib/liquidity.test.ts
import { calculateLiquidityScore } from "./liquidity";

describe("calculateLiquidityScore", () => {
  it("should return high score for liquid market", () => {
    const market = {
      totalVolume: 100000,
      bidAskSpread: 0.01,
      activeTraders: 500,
      lastTradeTime: new Date(),
    };

    const score = calculateLiquidityScore(market);

    expect(score).toBeGreaterThan(80);
    expect(score).toBeLessThanOrEqual(100);
  });

  it("should return low score for illiquid market", () => {
    const market = {
      totalVolume: 100,
      bidAskSpread: 0.5,
      activeTraders: 2,
      lastTradeTime: new Date(Date.now() - 86400000), // 1 day ago
    };

    const score = calculateLiquidityScore(market);

    expect(score).toBeLessThan(30);
    expect(score).toBeGreaterThanOrEqual(0);
  });

  it("should handle edge case: zero volume", () => {
    const market = {
      totalVolume: 0,
      bidAskSpread: 0,
      activeTraders: 0,
      lastTradeTime: new Date(),
    };

    const score = calculateLiquidityScore(market);

    expect(score).toBe(0);
  });
});
```

## Step 3: Run Tests - Verify FAIL

```bash
npm test lib/liquidity.test.ts

FAIL lib/liquidity.test.ts
  ✕ should return high score for liquid market (2 ms)
    Error: Not implemented

1 test failed, 0 passed
```

✅ テストは想定通り失敗。実装へ。

## Step 4: Implement Minimal Code (GREEN)

```typescript
// lib/liquidity.ts
export function calculateLiquidityScore(market: MarketData): number {
  // Handle zero volume edge case
  if (market.totalVolume === 0) {
    return 0;
  }

  // Calculate component scores (0-100 scale)
  const volumeScore = Math.min(market.totalVolume / 1000, 100);
  const spreadScore = Math.max(100 - market.bidAskSpread * 1000, 0);
  const traderScore = Math.min(market.activeTraders / 10, 100);

  // Recent activity bonus
  const hoursSinceLastTrade =
    (Date.now() - market.lastTradeTime.getTime()) / (1000 * 60 * 60);
  const recencyScore = Math.max(100 - hoursSinceLastTrade * 10, 0);

  // Weighted average
  const score =
    volumeScore * 0.4 +
    spreadScore * 0.3 +
    traderScore * 0.2 +
    recencyScore * 0.1;

  return Math.min(Math.max(score, 0), 100); // Clamp to 0-100
}
```

## Step 5: Run Tests - Verify PASS

```bash
npm test lib/liquidity.test.ts

PASS lib/liquidity.test.ts
  ✓ should return high score for liquid market (3 ms)
  ✓ should return low score for illiquid market (2 ms)
  ✓ should handle edge case: zero volume (1 ms)

3 tests passed
```

✅ 全テスト通過！

## Step 6: Refactor (IMPROVE)

```typescript
// lib/liquidity.ts - Refactored with constants and better readability
const WEIGHTS = {
  VOLUME: 0.4,
  SPREAD: 0.3,
  TRADERS: 0.2,
  RECENCY: 0.1,
} as const;

const SCALE_FACTORS = {
  VOLUME: 1000,
  SPREAD: 1000,
  TRADERS: 10,
  RECENCY_PENALTY: 10,
} as const;

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

export function calculateLiquidityScore(market: MarketData): number {
  if (market.totalVolume === 0) return 0;

  const volumeScore = Math.min(market.totalVolume / SCALE_FACTORS.VOLUME, 100);
  const spreadScore = clamp(
    100 - market.bidAskSpread * SCALE_FACTORS.SPREAD,
    0,
    100,
  );
  const traderScore = Math.min(
    market.activeTraders / SCALE_FACTORS.TRADERS,
    100,
  );

  const hoursSinceLastTrade =
    (Date.now() - market.lastTradeTime.getTime()) / (1000 * 60 * 60);
  const recencyScore = clamp(
    100 - hoursSinceLastTrade * SCALE_FACTORS.RECENCY_PENALTY,
    0,
    100,
  );

  const weightedScore =
    volumeScore * WEIGHTS.VOLUME +
    spreadScore * WEIGHTS.SPREAD +
    traderScore * WEIGHTS.TRADERS +
    recencyScore * WEIGHTS.RECENCY;

  return clamp(weightedScore, 0, 100);
}
```

## Step 7: Verify Tests Still Pass

```bash
npm test lib/liquidity.test.ts

PASS lib/liquidity.test.ts
  ✓ should return high score for liquid market (3 ms)
  ✓ should return low score for illiquid market (2 ms)
  ✓ should handle edge case: zero volume (1 ms)

3 tests passed
```

✅ リファクタ完了、テストも通過。

## Step 8: Check Coverage

```bash
npm test -- --coverage lib/liquidity.test.ts

File           | % Stmts | % Branch | % Funcs | % Lines
---------------|---------|----------|---------|--------
liquidity.ts   |   100   |   100    |   100   |   100

Coverage: 100% ✅ (Target: 80%)
```

✅ TDD セッション完了！

```text

## TDD ベストプラクティス

**DO:**
- ✅ 実装前に必ずテストを書く
- ✅ 実装前にテストが失敗することを確認
- ✅ 最小実装でテストを通す
- ✅ テストが緑の間にリファクタ
- ✅ エッジケースとエラーを追加
- ✅ 80%+ カバレッジ（重要コードは 100%）

**DON'T:**
- ❌ テストより先に実装を書く
- ❌ 変更後にテストを実行しない
- ❌ 一度に書きすぎる
- ❌ 失敗テストを放置
- ❌ 実装詳細をテストする（挙動をテスト）
- ❌ 何でもモックする（統合テストを優先）

## 含めるべきテスト種別

**ユニットテスト**（関数レベル）:
- ハッピーパス
- エッジケース（空、null、最大値）
- エラー条件
- 境界値

**統合テスト**（コンポーネントレベル）:
- API エンドポイント
- DB 操作
- 外部サービス呼び出し
- React コンポーネントとフック

**E2E テスト**（`e2e-runner` エージェントを使用）:
- 重要ユーザーフロー
- 複数ステップ
- フルスタック統合

## カバレッジ要件

- **最低 80%** 全体
- **100% 必須**:
  - 金融計算
  - 認証ロジック
  - セキュリティ重要コード
  - 主要ビジネスロジック

## 重要事項

**必須**: 実装前にテストを書く。TDD サイクルは:

1. **RED** - 失敗するテストを書く
2. **GREEN** - テストを通す実装を書く
3. **REFACTOR** - 改善

RED を省略しない。テストより先にコードを書かない。

## 他コマンドとの連携

- 先に `/plan` で計画
- `/tdd` でテスト駆動実装
- ビルドエラー時は `/build-fix`
- `/code-review` でレビュー
- `/test-coverage` でカバレッジ確認

## 関連エージェント

このコマンドは以下の `tdd-guide` エージェントを使用:
`~/.claude/agents/tdd-guide.md`
```
