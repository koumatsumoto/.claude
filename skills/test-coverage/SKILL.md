---
name: test-coverage
description: テストカバレッジを分析し、80%未満のファイルに対して不足分のテストを生成する。
disable-model-invocation: true
---

# Test Coverage

テストカバレッジを分析し、不足分のテストを生成:

1. カバレッジ付きでテスト実行: npm test --coverage または pnpm test --coverage

2. カバレッジレポートを分析（coverage/coverage-summary.json）

3. 80% 未満のファイルを特定

4. 低カバレッジの各ファイルについて:
   - 未テストのコードパスを分析
   - 関数のユニットテストを生成
   - API の統合テストを生成
   - 重要フローの E2E テストを生成

5. 新しいテストが通ることを確認

6. 変更前/後のカバレッジを表示

7. 全体カバレッジを 80%+ に到達させる

重視点:

- ハッピーパス
- エラーハンドリング
- エッジケース（null, undefined, empty）
- 境界条件
