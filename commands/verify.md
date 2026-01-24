# 検証コマンド

現在のコードベースの状態に対して包括的な検証を実行する。

## 手順

以下の順序を厳守して実行:

1. **ビルド確認**
   - このプロジェクトのビルドコマンドを実行
   - 失敗したらエラーを報告して STOP

2. **型チェック**
   - TypeScript/型チェッカーを実行
   - エラーは file:line で全件報告

3. **Lint チェック**
   - Linter を実行
   - 警告とエラーを報告

4. **テストスイート**
   - 全テスト実行
   - 合格/失敗数を報告
   - カバレッジ割合を報告

5. **Console.log 監査**
   - ソースファイル内の console.log を検索
   - 位置を報告

6. **Git ステータス**
   - 未コミット変更を表示
   - 最終コミット以降の変更ファイルを表示

## 出力

簡潔な検証レポートを出す:

```text
VERIFICATION: [PASS/FAIL]

Build:    [OK/FAIL]
Types:    [OK/X errors]
Lint:     [OK/X issues]
Tests:    [X/Y passed, Z% coverage]
Secrets:  [OK/X found]
Logs:     [OK/X console.logs]

Ready for PR: [YES/NO]
```

重大問題があれば、修正提案つきで列挙する。

## 引数

$ARGUMENTS:

- `quick` - ビルド + 型のみ
- `full` - 全チェック（デフォルト）
- `pre-commit` - コミット用の関連チェック
- `pre-pr` - フルチェック + セキュリティスキャン
