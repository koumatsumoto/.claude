# フックシステム

## フック種別

- **PreToolUse**: ツール実行前（検証、パラメータ変更）
- **PostToolUse**: ツール実行後（自動フォーマット、チェック）
- **Stop**: セッション終了時（最終検証）

## 現在のフック（~/.claude/settings.json）

### PreToolUse

- **tmux リマインダー**: 長時間コマンド（npm / pnpm / yarn / cargo など）に tmux を提案
- **git push レビュー**: push 前に Zed を開いてレビュー
- **doc blocker**: 不要な .md/.txt 作成をブロック

### PostToolUse

- **PR 作成**: PR URL と GitHub Actions の状態を記録
- **Prettier**: JS/TS ファイル編集後に自動フォーマット
- **TypeScript チェック**: .ts/.tsx 編集後に tsc を実行
- **console.log 警告**: 編集ファイルに console.log があると警告

### Stop

- **console.log 監査**: セッション終了前に変更ファイルの console.log をチェック

## 自動承認の注意点

慎重に使用すること:

- 信頼でき、明確に定義された計画にのみ有効化
- 探索的作業では無効化
- dangerously-skip-permissions フラグは決して使わない
- `~/.claude.json` の `allowedTools` で設定する

## TodoWrite ベストプラクティス

TodoWrite ツールの用途:

- 複数ステップ作業の進捗管理
- 指示の理解確認
- リアルタイムの舵取り
- きめ細かな実装ステップの可視化

Todo リストで見えること:

- 手順の順序違い
- 抜け漏れ
- 不要な項目
- 粒度の誤り
- 要件の誤解
