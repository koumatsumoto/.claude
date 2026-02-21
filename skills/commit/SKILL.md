---
name: commit
description: Use when creating a git commit from current changes with a Conventional Commits message.
disable-model-invocation: true
argument-hint: "[message]"
---

# Commit

変更内容を確認し、Conventional Commits 形式で安全にコミットする。

## Workflow

1. `git status` で変更状態を確認する
2. `git diff` と `git diff --staged` で差分を確認する
3. 機密情報混入をチェックする
4. 必要ファイルのみ個別に `git add <file>` する
5. `type(scope): description` 形式でコミットする

## Message Rules

- タイトルは簡潔（目安 50 文字以内）
- 本文は以下の構造:
  - 作業指示内容: 何を依頼されたか
  - 計画と背景: なぜこの方法を選んだか
  - 実施内容: 具体的に何を変更したか
- 事実ベースで書く（推測は避ける）

## Safety Rules

- `git add -A` / `git add .` は使わない
- push はユーザーが明示した場合のみ実行する
- Co-Authored-By は付けない（グローバル設定で無効化済み）
