---
name: security-review
description: 認証追加、ユーザー入力処理、シークレット取り扱い、API エンドポイント作成、決済/機密機能実装時に使用。包括的なセキュリティチェックリストとパターンを提供。
---

# セキュリティレビュースキル

このスキルは、コードがセキュリティのベストプラクティスに従っているかを保証し、潜在的な脆弱性を特定する。

## 使うタイミング

- 認証/認可の実装
- ユーザー入力やファイルアップロードの扱い
- 新しい API エンドポイント作成
- シークレット/認証情報の扱い
- 決済機能の実装
- 機密データの保存/送信
- サードパーティ API 連携

## セキュリティチェックリスト

### 1. シークレット管理

#### ❌ 絶対にやらない

```typescript
const apiKey = "sk-proj-xxxxx"; // ハードコード
const dbPassword = "password123"; // ソース内
```

#### ✅ 必ずやる

```typescript
const apiKey = process.env.OPENAI_API_KEY;
const dbUrl = process.env.DATABASE_URL;

// シークレットの存在を確認
if (!apiKey) {
  throw new Error("OPENAI_API_KEY not configured");
}
```

#### 検証ステップ: シークレット管理

- [ ] ハードコードされた API キー/トークン/パスワードがない
- [ ] シークレットは環境変数
- [ ] `.env.local` が .gitignore にある
- [ ] git 履歴にシークレットがない
- [ ] 本番シークレットはホスティング側（Vercel/Railway）

### 2. 入力バリデーション

#### 常に入力を検証

```typescript
import { z } from "zod";

// バリデーションスキーマ
const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150),
});

// 検証してから処理
export async function createUser(input: unknown) {
  try {
    const validated = CreateUserSchema.parse(input);
    return await db.users.create(validated);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, errors: error.errors };
    }
    throw error;
  }
}
```

#### ファイルアップロードの検証

```typescript
function validateFileUpload(file: File) {
  // サイズ（最大 5MB）
  const maxSize = 5 * 1024 * 1024;
  if (file.size > maxSize) {
    throw new Error("File too large (max 5MB)");
  }

  // タイプ
  const allowedTypes = ["image/jpeg", "image/png", "image/gif"];
  if (!allowedTypes.includes(file.type)) {
    throw new Error("Invalid file type");
  }

  // 拡張子
  const allowedExtensions = [".jpg", ".jpeg", ".png", ".gif"];
  const extension = file.name.toLowerCase().match(/\.[^.]+$/)?.[0];
  if (!extension || !allowedExtensions.includes(extension)) {
    throw new Error("Invalid file extension");
  }

  return true;
}
```

#### 検証ステップ: 入力バリデーション

- [ ] すべての入力がスキーマ検証
- [ ] アップロード制限（サイズ/タイプ/拡張子）
- [ ] ユーザー入力を直接クエリに使わない
- [ ] ブラックリストではなくホワイトリスト
- [ ] エラーメッセージに機密情報が出ない

### 3. SQL インジェクション対策

#### ❌ SQL 文字列連結は禁止

```typescript
// 危険 - SQL Injection
const query = `SELECT * FROM users WHERE email = '${userEmail}'`;
await db.query(query);
```

#### ✅ 必ずパラメータ化

```typescript
// 安全 - パラメータ化
const { data } = await supabase
  .from("users")
  .select("*")
  .eq("email", userEmail);

// または raw SQL
await db.query("SELECT * FROM users WHERE email = $1", [userEmail]);
```

#### 検証ステップ: SQL インジェクション対策

- [ ] 全 DB クエリがパラメータ化
- [ ] SQL 文字列連結がない
- [ ] ORM/クエリビルダの使い方が正しい
- [ ] Supabase クエリがサニタイズされている

### 4. 認証と認可

#### JWT トークン扱い

```typescript
// ❌ NG: localStorage（XSS 脆弱）
localStorage.setItem("token", token);

// ✅ OK: httpOnly cookies
res.setHeader(
  "Set-Cookie",
  `token=${token}; HttpOnly; Secure; SameSite=Strict; Max-Age=3600`,
);
```

#### 認可チェック

```typescript
export async function deleteUser(userId: string, requesterId: string) {
  // 常に認可チェック
  const requester = await db.users.findUnique({
    where: { id: requesterId },
  });

  if (requester.role !== "admin") {
    return NextResponse.json({ error: "Unauthorized" }, { status: 403 });
  }

  // 削除実行
  await db.users.delete({ where: { id: userId } });
}
```

#### Row Level Security（Supabase）

```sql
-- 全テーブルで RLS 有効化
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- ユーザーは自分のデータのみ閲覧
CREATE POLICY "Users view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- ユーザーは自分のデータのみ更新
CREATE POLICY "Users update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);
```

#### 検証ステップ: 認証と認可

- [ ] トークンは httpOnly cookies
- [ ] センシティブ操作に認可チェック
- [ ] Supabase の RLS 有効
- [ ] ロールベースアクセス制御
- [ ] セッション管理が安全

### 5. XSS 対策

#### HTML のサニタイズ

```typescript
import DOMPurify from 'isomorphic-dompurify'

// ユーザー HTML は必ずサニタイズ
function renderUserContent(html: string) {
  const clean = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p'],
    ALLOWED_ATTR: []
  })
  return <div dangerouslySetInnerHTML={{ __html: clean }} />
}
```

#### Content Security Policy

```typescript
// next.config.js
const securityHeaders = [
  {
    key: "Content-Security-Policy",
    value: `
      default-src 'self';
      script-src 'self' 'unsafe-eval' 'unsafe-inline';
      style-src 'self' 'unsafe-inline';
      img-src 'self' data: https:;
      font-src 'self';
      connect-src 'self' https://api.example.com;
    `
      .replace(/\s{2,}/g, " ")
      .trim(),
  },
];
```

#### 検証ステップ: XSS 対策

- [ ] ユーザー HTML をサニタイズ
- [ ] CSP ヘッダー設定
- [ ] 動的コンテンツの未検証描画なし
- [ ] React の XSS 防御を活用

### 6. CSRF 対策

#### CSRF トークン

```typescript
import { csrf } from "@/lib/csrf";

export async function POST(request: Request) {
  const token = request.headers.get("X-CSRF-Token");

  if (!csrf.verify(token)) {
    return NextResponse.json({ error: "Invalid CSRF token" }, { status: 403 });
  }

  // Process request
}
```

#### SameSite Cookie

```typescript
res.setHeader(
  "Set-Cookie",
  `session=${sessionId}; HttpOnly; Secure; SameSite=Strict`,
);
```

#### 検証ステップ: CSRF 対策

- [ ] 状態変更操作に CSRF トークン
- [ ] 全 Cookie に SameSite=Strict
- [ ] Double-submit パターン

### 7. レート制限

#### API レート制限

```typescript
import rateLimit from "express-rate-limit";

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 分
  max: 100, // 15 分あたり 100 リクエスト
  message: "Too many requests",
});

// ルートへ適用
app.use("/api/", limiter);
```

#### 高コスト操作

```typescript
// 検索は強い制限
const searchLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 分
  max: 10, // 1 分あたり 10 件
  message: "Too many search requests",
});

app.use("/api/search", searchLimiter);
```

#### 検証ステップ: レート制限

- [ ] 全 API にレート制限
- [ ] 高コスト操作は厳しめ
- [ ] IP ベース制限
- [ ] ユーザー単位制限（認証済み）

### 8. 機密データ露出

#### ロギング

```typescript
// ❌ NG: 機密情報のログ
console.log("User login:", { email, password });
console.log("Payment:", { cardNumber, cvv });

// ✅ OK: 機密情報は伏せる
console.log("User login:", { email, userId });
console.log("Payment:", { last4: card.last4, userId });
```

#### エラーメッセージ

```typescript
// ❌ NG: 内部情報露出
catch (error) {
  return NextResponse.json(
    { error: error.message, stack: error.stack },
    { status: 500 }
  )
}

// ✅ OK: 汎用メッセージ
catch (error) {
  console.error('Internal error:', error)
  return NextResponse.json(
    { error: 'An error occurred. Please try again.' },
    { status: 500 }
  )
}
```

#### 検証ステップ: 機密データ露出

- [ ] パスワード/トークン/シークレットをログに出さない
- [ ] ユーザー向けエラーは汎用的
- [ ] 詳細はサーバーログのみ
- [ ] スタックトレース露出なし

### 9. ブロックチェーンセキュリティ（Solana）

#### ウォレット検証

```typescript
import { verify } from "@solana/web3.js";

async function verifyWalletOwnership(
  publicKey: string,
  signature: string,
  message: string,
) {
  try {
    const isValid = verify(
      Buffer.from(message),
      Buffer.from(signature, "base64"),
      Buffer.from(publicKey, "base64"),
    );
    return isValid;
  } catch (error) {
    return false;
  }
}
```

#### トランザクション検証

```typescript
async function verifyTransaction(transaction: Transaction) {
  // 受取人を確認
  if (transaction.to !== expectedRecipient) {
    throw new Error("Invalid recipient");
  }

  // 金額を検証
  if (transaction.amount > maxAmount) {
    throw new Error("Amount exceeds limit");
  }

  // 残高確認
  const balance = await getBalance(transaction.from);
  if (balance < transaction.amount) {
    throw new Error("Insufficient balance");
  }

  return true;
}
```

#### 検証ステップ: ブロックチェーンセキュリティ

- [ ] ウォレット署名を検証
- [ ] トランザクション詳細を検証
- [ ] 取引前に残高確認
- [ ] 盲目的な署名をしない

### 10. 依存関係セキュリティ

#### 定期更新

```bash
# 脆弱性確認
npm audit

# 自動修正
npm audit fix

# 依存更新
npm update

# 古いパッケージを確認
npm outdated
```

#### ロックファイル

```bash
# ロックファイルは必ずコミット
git add package-lock.json

# CI では再現性あるビルド
npm ci  # npm install ではなくこちら
```

#### 検証ステップ: 依存関係セキュリティ

- [ ] 依存が最新
- [ ] npm audit がクリーン
- [ ] ロックファイルがコミット済み
- [ ] Dependabot 有効化
- [ ] 定期的にセキュリティ更新

## セキュリティテスト

### 自動セキュリティテスト

```typescript
// 認証テスト
test("requires authentication", async () => {
  const response = await fetch("/api/protected");
  expect(response.status).toBe(401);
});

// 認可テスト
test("requires admin role", async () => {
  const response = await fetch("/api/admin", {
    headers: { Authorization: `Bearer ${userToken}` },
  });
  expect(response.status).toBe(403);
});

// 入力バリデーション
test("rejects invalid input", async () => {
  const response = await fetch("/api/users", {
    method: "POST",
    body: JSON.stringify({ email: "not-an-email" }),
  });
  expect(response.status).toBe(400);
});

// レート制限
test("enforces rate limits", async () => {
  const requests = Array(101)
    .fill(null)
    .map(() => fetch("/api/endpoint"));

  const responses = await Promise.all(requests);
  const tooManyRequests = responses.filter((r) => r.status === 429);

  expect(tooManyRequests.length).toBeGreaterThan(0);
});
```

## デプロイ前セキュリティチェック

本番デプロイ前に必ず:

- [ ] **Secrets**: ハードコードなし、env 管理
- [ ] **Input Validation**: 全入力検証
- [ ] **SQL Injection**: パラメータ化
- [ ] **XSS**: コンテンツサニタイズ
- [ ] **CSRF**: 対策有効
- [ ] **Authentication**: トークン管理適切
- [ ] **Authorization**: 権限チェック
- [ ] **Rate Limiting**: 全エンドポイントで有効
- [ ] **HTTPS**: 本番で強制
- [ ] **Security Headers**: CSP / X-Frame-Options 設定
- [ ] **Error Handling**: 機密情報なし
- [ ] **Logging**: 機密情報ログなし
- [ ] **Dependencies**: 最新、脆弱性なし
- [ ] **Row Level Security**: Supabase で有効
- [ ] **CORS**: 適切な設定
- [ ] **File Uploads**: サイズ/タイプ検証
- [ ] **Wallet Signatures**: 検証（ブロックチェーン）

## リソース

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Next.js Security](https://nextjs.org/docs/security)
- [Supabase Security](https://supabase.com/docs/guides/auth)
- [Web Security Academy](https://portswigger.net/web-security)

---

**覚えておくこと**: セキュリティは任意ではない。1 つの脆弱性がプラットフォーム全体を危険に晒す。迷ったら慎重側に倒すこと。
