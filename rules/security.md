# セキュリティガイドライン

## 必須セキュリティチェック

**あらゆるコミット前に:**

- [ ] ハードコードされた機密情報がない（API キー / パスワード / トークン）
- [ ] すべてのユーザー入力が検証されている
- [ ] SQL インジェクション対策（パラメータ化クエリ）
- [ ] XSS 対策（HTML サニタイズ）
- [ ] CSRF 保護が有効
- [ ] 認証 / 認可が検証されている
- [ ] すべてのエンドポイントにレート制限
- [ ] エラーメッセージに機密情報が含まれない

## シークレット管理

```typescript
// NEVER: ハードコードされた秘密
const apiKey = "sk-proj-xxxxx";

// ALWAYS: 環境変数
const apiKey = process.env.OPENAI_API_KEY;

if (!apiKey) {
  throw new Error("OPENAI_API_KEY not configured");
}
```

## セキュリティ対応プロトコル

セキュリティ問題を発見した場合:

1. ただちに停止
2. **security-reviewer** エージェントを使う
3. CRITICAL 問題を解決してから継続
4. 露出したシークレットをローテーション
5. 類似問題がないか全コードベースを確認
