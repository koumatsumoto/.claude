---
description: 好みのパッケージマネージャー（npm/pnpm/yarn/bun）を設定する
disable-model-invocation: true
---

# パッケージマネージャー設定

このプロジェクトまたはグローバルで好みのパッケージマネージャーを設定する。

## 使い方

```bash
# 現在のパッケージマネージャーを検出
node scripts/setup-package-manager.js --detect

# グローバル設定
node scripts/setup-package-manager.js --global pnpm

# プロジェクト設定
node scripts/setup-package-manager.js --project bun

# 利用可能なパッケージマネージャーを一覧
node scripts/setup-package-manager.js --list
```

## 検出の優先順位

どのパッケージマネージャーを使うかは、以下の順で判定される:

1. **環境変数**: `CLAUDE_PACKAGE_MANAGER`
2. **プロジェクト設定**: `.claude/package-manager.json`
3. **package.json**: `packageManager` フィールド
4. **ロックファイル**: package-lock.json / yarn.lock / pnpm-lock.yaml / bun.lockb の存在
5. **グローバル設定**: `~/.claude/package-manager.json`
6. **フォールバック**: 最初に見つかったパッケージマネージャー（pnpm > bun > yarn > npm）

## 設定ファイル

### グローバル設定

```json
// ~/.claude/package-manager.json
{
  "packageManager": "pnpm"
}
```

### プロジェクト設定

```json
// .claude/package-manager.json
{
  "packageManager": "bun"
}
```

### package.json

```json
{
  "packageManager": "pnpm@8.6.0"
}
```

## 環境変数

他の検出方法より優先したい場合は `CLAUDE_PACKAGE_MANAGER` を設定:

```bash
# Windows (PowerShell)
$env:CLAUDE_PACKAGE_MANAGER = "pnpm"

# macOS/Linux
export CLAUDE_PACKAGE_MANAGER=pnpm
```

## 検出を実行

現在の検出結果を確認:

```bash
node scripts/setup-package-manager.js --detect
```
