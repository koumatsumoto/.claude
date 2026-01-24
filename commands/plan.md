---
description: 要件を再整理し、リスクを評価し、手順化した実装計画を作る。コードに触る前にユーザー確認を必ず待つ。
---

# Plan コマンド

このコマンドは **planner** エージェントを起動し、コードを書く前に包括的な実装計画を作成する。

## このコマンドが行うこと

1. **要件の再整理** - 何を作るか明確化
2. **リスク特定** - 想定される問題やブロッカーの洗い出し
3. **手順化** - 実装をフェーズに分解
4. **確認待ち** - 必ずユーザー承認後に進行

## 使うタイミング

`/plan` を使うのは:

- 新機能開始時
- 重要なアーキテクチャ変更
- 複雑なリファクタ
- 複数ファイルに影響が及ぶ場合
- 要件が曖昧/不明瞭な場合

## 動作

planner エージェントは以下を行う:

1. 依頼を分析し、要件を明確に言い換える
2. フェーズに分解して具体的な手順を提示
3. コンポーネント間の依存を特定
4. リスクやブロッカーを評価
5. 複雑度（高/中/低）を見積もる
6. 計画を提示し、**明示的な承認** を待つ

## 使用例

```text
User: /plan I need to add real-time notifications when markets resolve

Agent (planner):
# Implementation Plan: Real-Time Market Resolution Notifications

## Requirements Restatement
- Send notifications to users when markets they're watching resolve
- Support multiple notification channels (in-app, email, webhook)
- Ensure notifications are delivered reliably
- Include market outcome and user's position result

## Implementation Phases

### Phase 1: Database Schema
- Add notifications table with columns: id, user_id, market_id, type, status,
  created_at
- Add user_notification_preferences table for channel preferences
- Create indexes on user_id and market_id for performance

### Phase 2: Notification Service
- Create notification service in lib/notifications.ts
- Implement notification queue using BullMQ/Redis
- Add retry logic for failed deliveries
- Create notification templates

### Phase 3: Integration Points
- Hook into market resolution logic (when status changes to "resolved")
- Query all users with positions in market
- Enqueue notifications for each user

### Phase 4: Frontend Components
- Create NotificationBell component in header
- Add NotificationList modal
- Implement real-time updates via Supabase subscriptions
- Add notification preferences page

## Dependencies
- Redis (for queue)
- Email service (SendGrid/Resend)
- Supabase real-time subscriptions

## Risks
- HIGH: Email deliverability (SPF/DKIM required)
- MEDIUM: Performance with 1000+ users per market
- MEDIUM: Notification spam if markets resolve frequently
- LOW: Real-time subscription overhead

## Estimated Complexity: MEDIUM
- Backend: 4-6 hours
- Frontend: 3-4 hours
- Testing: 2-3 hours
- Total: 9-13 hours

**WAITING FOR CONFIRMATION**: Proceed with this plan? (yes/no/modify)
```

## 重要事項

**重要**: planner エージェントは、あなたが "yes" / "proceed" などで明示的に承認するまで **コードを書かない**。

修正したい場合は:

- "modify: [変更内容]"
- "different approach: [代案]"
- "skip phase 2 and do phase 3 first"

## 他コマンドとの連携

計画後:

- `/tdd` でテスト駆動実装
- ビルドエラーは `/build-and-fix`
- `/code-review` でレビュー

## 関連エージェント

このコマンドは `planner` エージェントを使用:
`~/.claude/agents/planner.md`
