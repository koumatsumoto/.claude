# コーデマップ更新

コードベース構造を解析してアーキテクチャドキュメントを更新する:

1. すべてのソースファイルをスキャンし、import/export/依存関係を把握
2. トークン節約型のコーデマップを以下形式で生成:
   - codemaps/architecture.md - 全体アーキテクチャ
   - codemaps/backend.md - バックエンド構造
   - codemaps/frontend.md - フロントエンド構造
   - codemaps/data.md - データモデルとスキーマ

3. 以前のバージョンからの差分率を算出
4. 変更が 30% を超える場合は更新前にユーザー承認
5. 各コーデマップに更新日を追加
6. レポートを .reports/codemap-diff.txt に保存

TypeScript/Node.js を使って分析し、実装詳細ではなく構造に集中する。
