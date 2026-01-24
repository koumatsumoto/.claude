---
name: continuous-learning
description: Claude Code セッションから再利用可能パターンを自動抽出し、学習スキルとして保存する。
---

# 継続学習スキル

セッション終了時に Claude Code セッションを自動評価し、再利用可能なパターンを抽出して学習スキルとして保存する。

## 仕組み

このスキルはセッション終了時の **Stop フック** として動作:

1. **セッション評価**: メッセージ数が十分か確認（デフォルト 10+）
2. **パターン検出**: 抽出できるパターンを特定
3. **スキル抽出**: `~/.claude/skills/learned/` に保存

## 設定

`config.json` でカスタマイズ:

```json
{
  "min_session_length": 10,
  "extraction_threshold": "medium",
  "auto_approve": false,
  "learned_skills_path": "~/.claude/skills/learned/",
  "patterns_to_detect": [
    "error_resolution",
    "user_corrections",
    "workarounds",
    "debugging_techniques",
    "project_specific"
  ],
  "ignore_patterns": ["simple_typos", "one_time_fixes", "external_api_issues"]
}
```

## パターン種別

| パターン               | 説明                              |
| ---------------------- | --------------------------------- |
| `error_resolution`     | 特定エラーの解決方法              |
| `user_corrections`     | ユーザー修正からの学び            |
| `workarounds`          | フレームワーク/ライブラリの回避策 |
| `debugging_techniques` | 効果的なデバッグ手法              |
| `project_specific`     | プロジェクト固有の規約            |

## フック設定

`~/.claude/settings.json` に追加:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "./skills/continuous-learning/evaluate-session.sh"
          }
        ]
      }
    ]
  }
}
```

## なぜ Stop フック？

- **軽量**: セッション終了時に 1 回だけ実行
- **非ブロッキング**: 各メッセージのレイテンシを増やさない
- **完全な文脈**: セッション全体を参照可能

## 関連

- [ロングガイド](https://x.com/affaanmustafa/status/2014040193557471352) - 継続学習の節
- `/learn` コマンド - セッション中の手動抽出
