---
name: tdd-workflow
description: 新機能、バグ修正、リファクタ時に使用。ユニット/統合/E2E を含む 80%+ カバレッジのテスト駆動開発を強制する。
---

# テスト駆動開発ワークフロー

このスキルは、全ての開発が TDD 原則と十分なテストカバレッジに従うことを保証する。

## 使うタイミング

- 新機能/機能の実装
- バグ修正
- 既存コードのリファクタ
- API エンドポイント追加
- 新規コンポーネント作成

## コア原則

### 1. テストが先

常にテストを先に書き、通るように実装する。

### 2. カバレッジ要件

- 最低 80%（ユニット + 統合 + E2E）
- エッジケースを全て網羅
- エラーシナリオをテスト
- 境界条件を検証

### 3. テスト種別

#### ユニットテスト

- 個別関数/ユーティリティ
- コンポーネントロジック
- 純粋関数
- ヘルパー/ユーティリティ

#### 統合テスト

- API エンドポイント
- DB 操作
- サービス連携
- 外部 API 呼び出し

#### E2E テスト（Playwright）

- 重要ユーザーフロー
- 完全なワークフロー
- ブラウザ自動化
- UI インタラクション

## TDD ワークフロー手順

### Step 1: ユーザージャーニーを書く

```text
As a [role], I want to [action], so that [benefit]

Example:
As a user, I want to search for markets semantically,
so that I can find relevant markets even without exact keywords.
```

### Step 2: テストケース生成

各ジャーニーごとに包括的なテストを書く:

```typescript
describe("Semantic Search", () => {
  it("returns relevant markets for query", async () => {
    // Test implementation
  });

  it("handles empty query gracefully", async () => {
    // Test edge case
  });

  it("falls back to substring search when Redis unavailable", async () => {
    // Test fallback behavior
  });

  it("sorts results by similarity score", async () => {
    // Test sorting logic
  });
});
```

### Step 3: テスト実行（失敗が前提）

```bash
npm test
# 実装前なので失敗するはず
```

### Step 4: 実装

テストが通る最小実装を書く:

```typescript
// Implementation guided by tests
export async function searchMarkets(query: string) {
  // Implementation here
}
```

### Step 5: 再度テスト

```bash
npm test
# テストが通るはず
```

### Step 6: リファクタ

テストを緑のまま品質改善:

- 重複削除
- 命名改善
- パフォーマンス改善
- 可読性向上

### Step 7: カバレッジ確認

```bash
npm run test:coverage
# 80%+ を確認
```

## テストパターン

### ユニットテストパターン（Jest/Vitest）

```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from './Button'

describe('Button Component', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click</Button>)

    fireEvent.click(screen.getByRole('button'))

    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})
```

### API 統合テストパターン

```typescript
import { NextRequest } from "next/server";
import { GET } from "./route";

describe("GET /api/markets", () => {
  it("returns markets successfully", async () => {
    const request = new NextRequest("http://localhost/api/markets");
    const response = await GET(request);
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data.success).toBe(true);
    expect(Array.isArray(data.data)).toBe(true);
  });

  it("validates query parameters", async () => {
    const request = new NextRequest(
      "http://localhost/api/markets?limit=invalid",
    );
    const response = await GET(request);

    expect(response.status).toBe(400);
  });

  it("handles database errors gracefully", async () => {
    // Mock database failure
    const request = new NextRequest("http://localhost/api/markets");
    // Test error handling
  });
});
```

### E2E テストパターン（Playwright）

```typescript
import { test, expect } from "@playwright/test";

test("user can search and filter markets", async ({ page }) => {
  // Navigate to markets page
  await page.goto("/");
  await page.click('a[href="/markets"]');

  // Verify page loaded
  await expect(page.locator("h1")).toContainText("Markets");

  // Search for markets
  await page.fill('input[placeholder="Search markets"]', "election");

  // Wait for debounce and results
  await page.waitForTimeout(600);

  // Verify search results displayed
  const results = page.locator('[data-testid="market-card"]');
  await expect(results).toHaveCount(5, { timeout: 5000 });

  // Verify results contain search term
  const firstResult = results.first();
  await expect(firstResult).toContainText("election", { ignoreCase: true });

  // Filter by status
  await page.click('button:has-text("Active")');

  // Verify filtered results
  await expect(results).toHaveCount(3);
});

test("user can create a new market", async ({ page }) => {
  // Login first
  await page.goto("/creator-dashboard");

  // Fill market creation form
  await page.fill('input[name="name"]', "Test Market");
  await page.fill('textarea[name="description"]', "Test description");
  await page.fill('input[name="endDate"]', "2025-12-31");

  // Submit form
  await page.click('button[type="submit"]');

  // Verify success message
  await expect(page.locator("text=Market created successfully")).toBeVisible();

  // Verify redirect to market page
  await expect(page).toHaveURL(/\/markets\/test-market/);
});
```

## テストファイル構成

```text
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx          # ユニットテスト
│   │   └── Button.stories.tsx       # Storybook
│   └── MarketCard/
│       ├── MarketCard.tsx
│       └── MarketCard.test.tsx
├── app/
│   └── api/
│       └── markets/
│           ├── route.ts
│           └── route.test.ts         # 統合テスト
└── e2e/
    ├── markets.spec.ts               # E2E テスト
    ├── trading.spec.ts
    └── auth.spec.ts
```

## 外部サービスのモック

### Supabase モック

```typescript
jest.mock("@/lib/supabase", () => ({
  supabase: {
    from: jest.fn(() => ({
      select: jest.fn(() => ({
        eq: jest.fn(() =>
          Promise.resolve({
            data: [{ id: 1, name: "Test Market" }],
            error: null,
          }),
        ),
      })),
    })),
  },
}));
```

### Redis モック

```typescript
jest.mock("@/lib/redis", () => ({
  searchMarketsByVector: jest.fn(() =>
    Promise.resolve([{ slug: "test-market", similarity_score: 0.95 }]),
  ),
  checkRedisHealth: jest.fn(() => Promise.resolve({ connected: true })),
}));
```

### OpenAI モック

```typescript
jest.mock("@/lib/openai", () => ({
  generateEmbedding: jest.fn(() =>
    Promise.resolve(
      new Array(1536).fill(0.1), // Mock 1536-dim embedding
    ),
  ),
}));
```

## カバレッジ検証

### レポート実行

```bash
npm run test:coverage
```

### 閾値

```json
{
  "jest": {
    "coverageThresholds": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

## よくあるテストの誤り

### ❌ NG: 実装詳細のテスト

```typescript
// 内部状態のテストはしない
expect(component.state.count).toBe(5);
```

### ✅ OK: ユーザー視点の挙動

```typescript
// ユーザーが見るものをテスト
expect(screen.getByText("Count: 5")).toBeInTheDocument();
```

### ❌ NG: 脆いセレクタ

```typescript
// 変わりやすい
await page.click(".css-class-xyz");
```

### ✅ OK: セマンティックセレクタ

```typescript
// 変更に強い
await page.click('button:has-text("Submit")');
await page.click('[data-testid="submit-button"]');
```

### ❌ NG: テストが相互依存

```typescript
// テスト同士が依存
test("creates user", () => {
  /* ... */
});
test("updates same user", () => {
  /* depends on previous test */
});
```

### ✅ OK: 独立したテスト

```typescript
// 各テストでデータ準備
test("creates user", () => {
  const user = createTestUser();
  // Test logic
});

test("updates user", () => {
  const user = createTestUser();
  // Update logic
});
```

## 継続テスト

### 開発中のウォッチ

```bash
npm test -- --watch
# ファイル変更で自動実行
```

### コミット前フック

```bash
# 各コミット前に実行
npm test && npm run lint
```

### CI/CD 連携

```yaml
# GitHub Actions
- name: Run Tests
  run: npm test -- --coverage
- name: Upload Coverage
  uses: codecov/codecov-action@v3
```

## ベストプラクティス

1. **テスト先行** - 常に TDD
2. **1 テスト 1 アサート** - 単一の挙動に集中
3. **説明的なテスト名** - 何をテストしているか明確に
4. **Arrange-Act-Assert** - 構造を明確に
5. **外部依存をモック** - ユニットを独立
6. **エッジケース** - null/undefined/empty/large
7. **エラーパスもテスト** - ハッピーパスだけでなく
8. **テストを高速に** - ユニットは 50ms 未満
9. **後片付け** - 副作用を残さない
10. **カバレッジを確認** - 欠落を検出

## 成功指標

- 80%+ カバレッジ達成
- 全テストが緑
- スキップ/無効化テストなし
- テスト実行が高速（ユニット 30 秒未満）
- E2E が重要フローを網羅
- 本番前にバグを捕捉

---

**覚えておくこと**: テストは任意ではない。安心してリファクタし、迅速に開発し、本番の信頼性を担保する安全網。
