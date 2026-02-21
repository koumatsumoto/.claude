---
name: refactor-clean
description: テスト検証つきで安全にデッドコードを特定・削除する。knip/depcheck/ts-prune で分析。
disable-model-invocation: true
---

# Refactor Clean

テスト検証つきで安全にデッドコードを特定・削除する:

1. デッドコード解析ツールを実行:
   - knip: 未使用 export と未使用ファイル
   - depcheck: 未使用依存
   - ts-prune: 未使用 TypeScript export

2. .reports/dead-code-analysis.md に包括的なレポートを生成

3. 重大度で分類:
   - SAFE: テストファイル、未使用ユーティリティ
   - CAUTION: API ルート、コンポーネント
   - DANGER: 設定ファイル、メインエントリ

4. 安全な削除のみ提案

5. 削除前に必ず:
   - 全テストを実行
   - テスト通過を確認
   - 変更を適用
   - 再度テスト
   - 失敗したらロールバック

6. クリーンアップ項目のサマリを表示

テストを走らせずに削除しないこと。
