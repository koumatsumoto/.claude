---
name: commit
description: 変更内容を git commit する。Conventional Commits 形式でコミットメッセージを作成する。
disable-model-invocation: true
argument-hint: "[message]"
---

# Commit

変更差分を確認し、Conventional Commits 形式でコミットメッセージを作成して git commit する。

## Commit Message

Conventional Commits 形式に従う:

- タイトル: 50 文字以内、命令形で記述
- 形式: `type(scope): description`
- 3 行目以降に箇条書きで詳細説明を記載

コミットメッセージの詳細説明には以下の 3 項目を含める:

1. **作業指示内容**: ユーザーから受けた指示の要約。何を依頼されたか
2. **計画とその背景・理由**: 採用したアプローチとその理由。なぜこの方法を選んだか
3. **実際の作業内容**: 具体的に行った変更内容。何をどう変更したか

### サンプル

```text
feat(auth): JWT トークンのリフレッシュ機能を追加

## 作業指示内容
- ログイン状態がすぐ切れる問題の解消を依頼された
- トークンの自動更新機能が必要

## 作業計画と背景・理由
- リフレッシュトークン方式を採用し、UX を損なわず安全に延長
- httpOnly cookie でリフレッシュトークンを管理し XSS リスクを低減

## 実際の作業内容
- lib/auth/refresh.ts を新規作成
- middleware.ts にトークン検証・更新ロジックを追加
- テスト 12 件を追加（カバレッジ 85%）
```

## コミット手順

`/commit` 実行時の処理:

1. **変更確認**: `git status` で未追跡ファイル・変更を確認
2. **差分分析**: `git diff` でステージ済み・未ステージの変更を確認
3. **履歴確認**: `git log --oneline -5` で直近のコミットスタイルを参照
4. **セキュリティチェック**: 以下が含まれていないか確認
   - ハードコードされた API キー・パスワード・トークン
   - .env ファイルや credentials.json
   - 機密情報を含むファイル
5. **メッセージ作成**: 変更内容を分析し、上記形式でメッセージを生成
6. **ステージング**: 対象ファイルを個別に `git add`（`git add -A` は使わない）
7. **コミット実行**: HEREDOC 形式でコミット

```bash
git commit -m "$(cat <<'EOF'
type(scope): description

## 作業指示内容
- ...

## 作業計画と背景・理由
- ...

## 実際の作業内容
- ...
EOF
)"
```

## 注意事項

- Attribution（Co-Authored-By）はグローバル設定で無効化済み。付けない
- `git add -A` や `git add .` は使わない。ファイルを個別に指定する
- コミット前に `/code-review` で品質チェックを推奨
- push は `/commit` の範囲外。ユーザーが明示的に指示した場合のみ実行する

## 関連スキル

- `/code-review` - コミット前の品質レビュー
- `/plan` - 実装前の計画整理
