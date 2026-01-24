---
name: coding-standards
description: >-
  TypeScript / JavaScript / React / Node.js 開発向けの汎用コーディング標準、
  ベストプラクティス、パターン。
---

# コーディング標準 & ベストプラクティス

全プロジェクトに適用できる汎用コーディング標準。

## コード品質の原則

### 1. 可読性最優先

- コードは書くより読む方が多い
- 明確な変数/関数名
- コメントより自己説明的なコード
- 一貫したフォーマット

### 2. KISS（Keep It Simple, Stupid）

- 動く最小の解決策
- 過剰設計を避ける
- 早すぎる最適化をしない
- 賢いコードより分かりやすさ

### 3. DRY（Don't Repeat Yourself）

- 共通ロジックを関数化
- 再利用可能なコンポーネント
- ユーティリティ共有
- コピペを避ける

### 4. YAGNI（You Aren't Gonna Need It）

- 必要になるまで作らない
- 憶測の一般化を避ける
- 必要時のみ複雑さを追加
- まずはシンプル、必要ならリファクタ

## TypeScript/JavaScript 標準

### 変数命名

```typescript
// ✅ GOOD: 説明的な名前
const marketSearchQuery = "election";
const isUserAuthenticated = true;
const totalRevenue = 1000;

// ❌ BAD: 意味が不明
const q = "election";
const flag = true;
const x = 1000;
```

### 関数命名

```typescript
// ✅ GOOD: 動詞 + 名詞
async function fetchMarketData(marketId: string) {}
function calculateSimilarity(a: number[], b: number[]) {}
function isValidEmail(email: string): boolean {}

// ❌ BAD: 不明瞭/名詞のみ
async function market(id: string) {}
function similarity(a, b) {}
function email(e) {}
```

### イミュータビリティ（重要）

```typescript
// ✅ ALWAYS: スプレッドで更新
const updatedUser = {
  ...user,
  name: "New Name",
};

const updatedArray = [...items, newItem];

// ❌ NEVER: 直接ミューテーション
user.name = "New Name"; // BAD
items.push(newItem); // BAD
```

### エラーハンドリング

```typescript
// ✅ GOOD: 包括的なエラーハンドリング
async function fetchData(url: string) {
  try {
    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.error("Fetch failed:", error);
    throw new Error("Failed to fetch data");
  }
}

// ❌ BAD: エラー処理なし
async function fetchData(url) {
  const response = await fetch(url);
  return response.json();
}
```

### Async/Await ベストプラクティス

```typescript
// ✅ GOOD: 可能なら並列実行
const [users, markets, stats] = await Promise.all([
  fetchUsers(),
  fetchMarkets(),
  fetchStats(),
]);

// ❌ BAD: 不要な逐次実行
const users = await fetchUsers();
const markets = await fetchMarkets();
const stats = await fetchStats();
```

### 型安全性

```typescript
// ✅ GOOD: 適切な型
interface Market {
  id: string;
  name: string;
  status: "active" | "resolved" | "closed";
  created_at: Date;
}

function getMarket(id: string): Promise<Market> {
  // Implementation
}

// ❌ BAD: any 使用
function getMarket(id: any): Promise<any> {
  // Implementation
}
```

## React ベストプラクティス

### コンポーネント構造

```typescript
// ✅ GOOD: 型付き関数コンポーネント
interface ButtonProps {
  children: React.ReactNode
  onClick: () => void
  disabled?: boolean
  variant?: 'primary' | 'secondary'
}

export function Button({
  children,
  onClick,
  disabled = false,
  variant = 'primary'
}: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`btn btn-${variant}`}
    >
      {children}
    </button>
  )
}

// ❌ BAD: 型なし
export function Button(props) {
  return <button onClick={props.onClick}>{props.children}</button>
}
```

### カスタムフック

```typescript
// ✅ GOOD: 再利用可能なフック
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(handler);
  }, [value, delay]);

  return debouncedValue;
}

// Usage
const debouncedQuery = useDebounce(searchQuery, 500);
```

### 状態管理

```typescript
// ✅ GOOD: 正しい状態更新
const [count, setCount] = useState(0);

// 以前の状態を使う更新
setCount((prev) => prev + 1);

// ❌ BAD: 直接参照（非同期で古くなる）
setCount(count + 1);
```

### 条件付きレンダリング

```typescript
// ✅ GOOD: 明確な条件分岐
{isLoading && <Spinner />}
{error && <ErrorMessage error={error} />}
{data && <DataDisplay data={data} />}

// ❌ BAD: 三項ネスト地獄
{
  isLoading ? (
    <Spinner />
  ) : error ? (
    <ErrorMessage error={error} />
  ) : data ? (
    <DataDisplay data={data} />
  ) : null
}
```

## API 設計標準

### REST API 規約

```text
GET    /api/markets              # 全マーケット
GET    /api/markets/:id          # 個別マーケット
POST   /api/markets              # マーケット作成
PUT    /api/markets/:id          # 全更新
PATCH  /api/markets/:id          # 部分更新
DELETE /api/markets/:id          # 削除

# フィルタ用クエリパラメータ
GET /api/markets?status=active&limit=10&offset=0
```

### レスポンス形式

```typescript
// ✅ GOOD: 一貫したレスポンス
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  meta?: {
    total: number;
    page: number;
    limit: number;
  };
}

// 成功レスポンス
return NextResponse.json({
  success: true,
  data: markets,
  meta: { total: 100, page: 1, limit: 10 },
});

// エラーレスポンス
return NextResponse.json(
  {
    success: false,
    error: "Invalid request",
  },
  { status: 400 },
);
```

### 入力バリデーション

```typescript
import { z } from "zod";

// ✅ GOOD: スキーマ検証
const CreateMarketSchema = z.object({
  name: z.string().min(1).max(200),
  description: z.string().min(1).max(2000),
  endDate: z.string().datetime(),
  categories: z.array(z.string()).min(1),
});

export async function POST(request: Request) {
  const body = await request.json();

  try {
    const validated = CreateMarketSchema.parse(body);
    // validated data を利用
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        {
          success: false,
          error: "Validation failed",
          details: error.errors,
        },
        { status: 400 },
      );
    }
  }
}
```

## ファイル構成

### プロジェクト構造

```text
src/
├── app/                    # Next.js App Router
│   ├── api/               # API routes
│   ├── markets/           # Market pages
│   └── (auth)/           # Auth pages (route groups)
├── components/            # React components
│   ├── ui/               # Generic UI components
│   ├── forms/            # Form components
│   └── layouts/          # Layout components
├── hooks/                # Custom React hooks
├── lib/                  # Utilities and configs
│   ├── api/             # API clients
│   ├── utils/           # Helper functions
│   └── constants/       # Constants
├── types/                # TypeScript types
└── styles/              # Global styles
```

### ファイル命名

```text
components/Button.tsx          # コンポーネントは PascalCase
hooks/useAuth.ts              # フックは camelCase + use
lib/formatDate.ts             # ユーティリティは camelCase
types/market.types.ts         # .types サフィックス
```

## コメント & ドキュメント

### コメントを書くタイミング

```typescript
// ✅ GOOD: WHAT ではなく WHY を説明
// API 障害時に過負荷を避けるため指数バックオフを使用
const delay = Math.min(1000 * Math.pow(2, retryCount), 30000);

// 大きな配列での性能優先のためミューテーションを使用
items.push(newItem);

// ❌ BAD: 説明の無駄
// Increment counter by 1
count++;

// Set name to user's name
name = user.name;
```

### 公開 API の JSDoc

````typescript
/**
 * Searches markets using semantic similarity.
 *
 * @param query - Natural language search query
 * @param limit - Maximum number of results (default: 10)
 * @returns Array of markets sorted by similarity score
 * @throws {Error} If OpenAI API fails or Redis unavailable
 *
 * @example
 * ```typescript
 * const results = await searchMarkets('election', 5)
 * console.log(results[0].name) // "Trump vs Biden"
 * ```
 */
export async function searchMarkets(
  query: string,
  limit: number = 10,
): Promise<Market[]> {
  // Implementation
}
````

## パフォーマンスベストプラクティス

### メモ化

```typescript
import { useMemo, useCallback } from "react";

// ✅ GOOD: 重い計算は useMemo
const sortedMarkets = useMemo(() => {
  return markets.sort((a, b) => b.volume - a.volume);
}, [markets]);

// ✅ GOOD: 子へ渡す関数は useCallback
const handleSearch = useCallback((query: string) => {
  setSearchQuery(query);
}, []);
```

### 遅延読み込み

```typescript
import { lazy, Suspense } from 'react'

// ✅ GOOD: 重いコンポーネントを遅延読み込み
const HeavyChart = lazy(() => import('./HeavyChart'))

export function Dashboard() {
  return (
    <Suspense fallback={<Spinner />}>
      <HeavyChart />
    </Suspense>
  )
}
```

### データベースクエリ

```typescript
// ✅ GOOD: 必要列のみ取得
const { data } = await supabase
  .from("markets")
  .select("id, name, status")
  .limit(10);

// ❌ BAD: 全列取得
const { data } = await supabase.from("markets").select("*");
```

## テスト標準

### テスト構造（AAA パターン）

```typescript
test("calculates similarity correctly", () => {
  // Arrange
  const vector1 = [1, 0, 0];
  const vector2 = [0, 1, 0];

  // Act
  const similarity = calculateCosineSimilarity(vector1, vector2);

  // Assert
  expect(similarity).toBe(0);
});
```

### テスト命名

```typescript
// ✅ GOOD: 説明的なテスト名
test("returns empty array when no markets match query", () => {});
test("throws error when OpenAI API key is missing", () => {});
test("falls back to substring search when Redis unavailable", () => {});

// ❌ BAD: 曖昧
test("works", () => {});
test("test search", () => {});
```

## コードスメル検知

以下のアンチパターンに注意:

### 1. 長すぎる関数

```typescript
// ❌ BAD: 50 行超
function processMarketData() {
  // 100 lines of code
}

// ✅ GOOD: 分割
function processMarketData() {
  const validated = validateData();
  const transformed = transformData(validated);
  return saveData(transformed);
}
```

### 2. 深いネスト

```typescript
// ❌ BAD: 5+ 階層のネスト
if (user) {
  if (user.isAdmin) {
    if (market) {
      if (market.isActive) {
        if (hasPermission) {
          // Do something
        }
      }
    }
  }
}

// ✅ GOOD: 早期 return
if (!user) return;
if (!user.isAdmin) return;
if (!market) return;
if (!market.isActive) return;
if (!hasPermission) return;

// Do something
```

### 3. マジックナンバー

```typescript
// ❌ BAD: 根拠不明
if (retryCount > 3) {
}
setTimeout(callback, 500);

// ✅ GOOD: 定数化
const MAX_RETRIES = 3;
const DEBOUNCE_DELAY_MS = 500;

if (retryCount > MAX_RETRIES) {
}
setTimeout(callback, DEBOUNCE_DELAY_MS);
```

**覚えておくこと**: コード品質は妥協できない。明確で保守しやすいコードが、迅速な開発と安心なリファクタを支える。
