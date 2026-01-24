---
description: >-
  Playwright で E2E テストを生成・実行する。テストジャーニーを作成し、テストを
  実行し、スクショ/動画/トレースを保存し、成果物をアップロードする。
---

# E2E コマンド

このコマンドは **e2e-runner** エージェントを呼び出し、Playwright を使って E2E テストを生成・保守・実行する。

## このコマンドが行うこと

1. **テストジャーニー生成** - ユーザーフローに対する Playwright テスト作成
2. **E2E テスト実行** - 複数ブラウザでの実行
3. **成果物収集** - 失敗時のスクショ/動画/トレース
4. **結果アップロード** - HTML レポートと JUnit XML
5. **フレイキー検出** - 不安定テストの隔離

## 使うタイミング

`/e2e` を使うのは:

- 重要なユーザージャーニーの検証（ログイン、取引、決済）
- 複数ステップのフローが E2E で動くか確認
- UI 操作とナビゲーションの検証
- フロント/バックの統合検証
- 本番デプロイ前の準備

## 動作

e2e-runner エージェントは以下を行う:

1. **ユーザーフローを分析** してテストシナリオを特定
2. **Playwright テストを生成**（Page Object Model）
3. **複数ブラウザで実行**（Chrome/Firefox/Safari）
4. **失敗時に成果物を取得**（スクショ、動画、トレース）
5. **結果レポートを生成**
6. **フレイキーテストを特定** して改善提案

## 使用例

````text
User: /e2e Test the market search and view flow

Agent (e2e-runner):
# E2E Test Generation: Market Search and View Flow

## Test Scenario Identified

**User Journey:** Market Search → View Results → Click Market → View Details

**Test Coverage:**
1. Navigate to markets page
2. Perform semantic search
3. Verify search results
4. Click on first result
5. Verify market details page loads
6. Verify chart renders

## Generated Test Code

```typescript
// tests/e2e/markets/search-and-view.spec.ts
import { test, expect } from '@playwright/test'
import { MarketsPage } from '../../pages/MarketsPage'
import { MarketDetailsPage } from '../../pages/MarketDetailsPage'

test.describe('Market Search and View Flow', () => {
  test('user can search markets and view details', async ({ page }) => {
    // 1. Navigate to markets page
    const marketsPage = new MarketsPage(page)
    await marketsPage.goto()

    // Verify page loaded
    await expect(page).toHaveTitle(/Markets/)
    await expect(page.locator('h1')).toContainText('Markets')

    // 2. Perform semantic search
    await marketsPage.searchMarkets('election')

    // Wait for API response
    await page.waitForResponse(resp =>
      resp.url().includes('/api/markets/search') && resp.status() === 200
    )

    // 3. Verify search results
    const marketCards = marketsPage.marketCards
    await expect(marketCards.first()).toBeVisible()
    const resultCount = await marketCards.count()
    expect(resultCount).toBeGreaterThan(0)

    // Take screenshot of search results
    await page.screenshot({ path: 'artifacts/search-results.png' })

    // 4. Click on first result
    const firstMarketTitle = await marketCards.first().textContent()
    await marketCards.first().click()

    // 5. Verify market details page loads
    await expect(page).toHaveURL(/\/markets\/[a-z0-9-]+/)

    const detailsPage = new MarketDetailsPage(page)
    await expect(detailsPage.marketName).toBeVisible()
    await expect(detailsPage.marketDescription).toBeVisible()

    // 6. Verify chart renders
    await expect(detailsPage.priceChart).toBeVisible()

    // Verify market name matches
    const detailsTitle = await detailsPage.marketName.textContent()
    expect(detailsTitle?.toLowerCase()).toContain(
      firstMarketTitle?.toLowerCase().substring(0, 20) || ''
    )

    // Take screenshot of market details
    await page.screenshot({ path: 'artifacts/market-details.png' })
  })

  test('search with no results shows empty state', async ({ page }) => {
    const marketsPage = new MarketsPage(page)
    await marketsPage.goto()

    // Search for non-existent market
    await marketsPage.searchMarkets('xyznonexistentmarket123456')

    // Verify empty state
    await expect(page.locator('[data-testid="no-results"]')).toBeVisible()
    await expect(page.locator('[data-testid="no-results"]')).toContainText(
      /no.*results|no.*markets/i
    )

    const marketCount = await marketsPage.marketCards.count()
    expect(marketCount).toBe(0)
  })

  test('can clear search and see all markets again', async ({ page }) => {
    const marketsPage = new MarketsPage(page)
    await marketsPage.goto()

    // Initial market count
    const initialCount = await marketsPage.marketCards.count()

    // Perform search
    await marketsPage.searchMarkets('trump')
    await page.waitForLoadState('networkidle')

    // Verify filtered results
    const filteredCount = await marketsPage.marketCards.count()
    expect(filteredCount).toBeLessThan(initialCount)

    // Clear search
    await marketsPage.searchInput.clear()
    await page.waitForLoadState('networkidle')

    // Verify all markets shown again
    const finalCount = await marketsPage.marketCards.count()
    expect(finalCount).toBe(initialCount)
  })
})
````

## テスト実行

```bash
# 生成したテストを実行
npx playwright test tests/e2e/markets/search-and-view.spec.ts

Running 3 tests using 3 workers

  ✓  [chromium] › search-and-view.spec.ts:5:3 ›
     user can search markets and view details (4.2s)
  ✓  [chromium] › search-and-view.spec.ts:52:3 ›
     search with no results shows empty state (1.8s)
  ✓  [chromium] › search-and-view.spec.ts:67:3 ›
     can clear search and see all markets again (2.9s)

  3 passed (9.1s)

Artifacts generated:
- artifacts/search-results.png
- artifacts/market-details.png
- playwright-report/index.html
```

## テストレポート

```text
╔══════════════════════════════════════════════════════════════╗
║                    E2E Test Results                          ║
╠══════════════════════════════════════════════════════════════╣
║ Status:     ✅ ALL TESTS PASSED                              ║
║ Total:      3 tests                                          ║
║ Passed:     3 (100%)                                         ║
║ Failed:     0                                                ║
║ Flaky:      0                                                ║
║ Duration:   9.1s                                             ║
╚══════════════════════════════════════════════════════════════╝

Artifacts:
📸 Screenshots: 2 files
📹 Videos: 0 files (only on failure)
🔍 Traces: 0 files (only on failure)
📊 HTML Report: playwright-report/index.html

View report: npx playwright show-report
```

✅ E2E テストスイートは CI/CD 連携可能！

````text

## テスト成果物

テスト実行時に以下を取得:

**全テストで取得:**
- HTML レポート（タイムラインと結果）
- CI 向け JUnit XML

**失敗時のみ取得:**
- 失敗時のスクリーンショット
- テスト動画
- トレースファイル（再生）
- ネットワークログ
- コンソールログ

## 成果物の確認

```bash
# HTML レポートを表示
npx playwright show-report

# 特定トレースを表示
npx playwright show-trace artifacts/trace-abc123.zip

# スクショは artifacts/ 配下
open artifacts/search-results.png
````

## フレイキーテスト検出

テストが断続的に失敗する場合:

```text
⚠️  FLAKY TEST DETECTED: tests/e2e/markets/trade.spec.ts

Test passed 7/10 runs (70% pass rate)

Common failure:
"Timeout waiting for element '[data-testid="confirm-btn"]'"

Recommended fixes:
1. Add explicit wait: await page.waitForSelector('[data-testid="confirm-btn"]')
2. Increase timeout: { timeout: 10000 }
3. Check for race conditions in component
4. Verify element is not hidden by animation

Quarantine recommendation: Mark as test.fixme() until fixed
```

## ブラウザ設定

デフォルトで複数ブラウザを実行:

- ✅ Chromium (Desktop Chrome)
- ✅ Firefox (Desktop)
- ✅ WebKit (Desktop Safari)
- ✅ Mobile Chrome (optional)

`playwright.config.ts` で調整。

## CI/CD 連携

CI に追加:

```yaml
# .github/workflows/e2e.yml
- name: Install Playwright
  run: npx playwright install --with-deps

- name: Run E2E tests
  run: npx playwright test

- name: Upload artifacts
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: playwright-report
    path: playwright-report/
```

## PMX 向け重要フロー

PMX では以下を優先:

**🔴 CRITICAL（必ず通す）:**

1. ウォレット接続
2. マーケット閲覧
3. マーケット検索（セマンティック検索）
4. マーケット詳細
5. 取引（テスト資金）
6. マーケット確定
7. 出金

**🟡 IMPORTANT:**

1. マーケット作成
2. ユーザープロフィール更新
3. リアルタイム価格更新
4. チャート描画
5. フィルタ/ソート
6. モバイル表示

## ベストプラクティス

**DO:**

- ✅ 保守性のため POM を使う
- ✅ data-testid をセレクタに使う
- ✅ 任意タイムアウトではなく API 応答を待つ
- ✅ 重要ジャーニーを E2E でテスト
- ✅ main マージ前に実行
- ✅ 失敗時は成果物を確認

**DON'T:**

- ❌ 壊れやすいセレクタ（CSS クラス）を使う
- ❌ 実装詳細のテスト
- ❌ 本番に対してテスト
- ❌ フレイキーを放置
- ❌ 失敗時に成果物を見ない
- ❌ 全てのエッジケースを E2E に寄せる（ユニットで補完）

## 重要事項

**PMX 向けの CRITICAL:**

- 実金を扱う E2E テストはテストネット/ステージングのみ
- 本番に対して取引テストを走らせない
- 金融テストには `test.skip(process.env.NODE_ENV === 'production')` を設定
- 小さなテスト資金のウォレットを使用

## 他コマンドとの連携

- `/plan` で重要ジャーニーを特定
- `/tdd` でユニットテスト
- `/e2e` で E2E テスト
- `/code-review` でテスト品質確認

## 関連エージェント

このコマンドは `e2e-runner` エージェントを使用:
`~/.claude/agents/e2e-runner.md`

## クイックコマンド

```bash
# 全 E2E テスト実行
npx playwright test

# 特定テスト実行
npx playwright test tests/e2e/markets/search.spec.ts

# GUI モード
npx playwright test --headed

# デバッグ
npx playwright test --debug

# テスト生成
npx playwright codegen http://localhost:3000

# レポート表示
npx playwright show-report
```
