---
paths:
  - "**/*.{ts,tsx}"
---

# コーディングスタイル

## イミュータビリティ（重要）

**常に新しいオブジェクトを作成し、決してミューテーションしないこと。**

```ts
// NG: ミューテーション
function updateUser(user, name) {
  user.name = name; // MUTATION!
  return user;
}

// OK: イミュータブル
function updateUser(user, name) {
  return {
    ...user,
    name,
  };
}
```

## ファイル構成

### 小さなファイル多数 > 大きなファイル少数

- 高い凝集度、低い結合度
- 200〜400 行が目安、最大 800 行
- 大きなコンポーネントからユーティリティを抽出
- 種別ではなく機能/ドメインで整理

## エラーハンドリング

**常に包括的にエラー処理すること。**

```ts
try {
  const result = await riskyOperation();
  return result;
} catch (error) {
  console.error("Operation failed:", error);
  throw new Error("Detailed user-friendly message");
}
```

## 入力バリデーション

**常にユーザー入力を検証すること。**

```ts
import { z } from "zod";

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150),
});

const validated = schema.parse(input);
```

## コード品質チェックリスト

作業完了とする前に:

- [ ] コードが読みやすく、命名が適切
- [ ] 関数が小さい（50 行未満）
- [ ] ファイルが集中している（800 行未満）
- [ ] 深いネストがない（4 階層超は NG）
- [ ] 適切なエラーハンドリング
- [ ] console.log がない
- [ ] ハードコード値がない
- [ ] ミューテーションしない（イミュータブルパターン使用）
