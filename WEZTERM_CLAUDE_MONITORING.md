# 🖥️ WezTerm Claude監視システム

WezTermの統合監視システムにより、Claude Code の実行状況と人間の操作状況をリアルタイムで可視化できます。

## ✨ 機能概要

### 🤖 Claude実行状況監視
- **リアルタイム検出**: CPU使用率ベースの状態判定
- **視覚的表示**: 絵文字とカラーコードによる状態表示
- **パフォーマンス最適化**: キャッシュ機能付きプロセス監視

### 👤 人間活動追跡
- **インタラクション監視**: キーボード・マウス操作の検出
- **アイドル時間表示**: 非アクティブ時間の可視化
- **効率性測定**: 作業パターンの把握

## 🎯 ステータス表示

### Claude状態インジケーター
| 絵文字 | 状態 | 説明 | CPU使用率 |
|--------|------|------|-----------|
| 🤖 | アイドル | 待機中 | < 1% |
| 💭 | 思考中 | 軽い処理実行中 | 1-5% |
| ⚡ | 実行中 | 高負荷処理実行中 | > 5% |

### 人間活動インジケーター
| 絵文字 | 状態 | 説明 |
|--------|------|------|
| 👤 | アクティブ | 5分以内に操作あり |
| 😴 | アイドル | 5分以上操作なし |

## 📊 ステータスバー表示例

```
👤 ⚡12.3% 🤖  my-nvim-config 14:30:15
```

- `👤` - ユーザーがアクティブ
- `⚡12.3%` - Claude実行中（CPU使用率12.3%）
- `🤖` - 他のClaudeプロセスがアイドル
- `my-nvim-config` - 現在のGitリポジトリ
- `14:30:15` - 現在時刻

## 🔧 設定詳細

### CPU監視設定
```lua
-- wezterm.lua内の設定
CLAUDE_CONSTANTS = {
  CPU_THRESHOLD_ACTIVE = 5.0,     -- アクティブ判定閾値
  HUMAN_IDLE_THRESHOLD = 300,     -- アイドル判定時間（秒）
}
```

### 更新間隔
```lua
config.status_update_interval = 250  -- 0.25秒ごとに更新
```

### キャッシュ設定
```lua
local cpu_cache_timeout = 2  -- CPU情報を2秒間キャッシュ
```

## 🔔 通知システム

### Claudeタスク完了通知
- **音声通知**: カスタムサウンドまたはシステムサウンド
- **トースト通知**: タスク完了メッセージ
- **通知時間**: 4秒間表示

### 通知設定
```lua
-- カスタムサウンドファイル
local sound_file = wezterm.home_dir .. '/.claude/perfect.mp3'

-- フォールバックサウンド（macOS）
local fallback_sound = '/System/Library/Sounds/Ping.aiff'
```

## 🎨 カスタマイズ

### 色の変更
```lua
CLAUDE_CONSTANTS = {
  COLOR_CLAUDE_IDLE = '#68d391',      -- アイドル時の色（緑）
  COLOR_CLAUDE_RUNNING = '#f6ad55',   -- 実行中の色（オレンジ）
  COLOR_CLAUDE_THINKING = '#a78bfa',  -- 思考中の色（紫）
  COLOR_HUMAN_ACTIVE = '#4fd1c7',     -- 人間アクティブ色（青緑）
  COLOR_HUMAN_IDLE = '#718096',       -- 人間アイドル色（グレー）
}
```

### 絵文字の変更
```lua
CLAUDE_CONSTANTS = {
  EMOJI_IDLE = '🤖',
  EMOJI_RUNNING = '⚡',
  EMOJI_THINKING = '💭',
  EMOJI_HUMAN_ACTIVE = '👤',
  EMOJI_HUMAN_IDLE = '😴',
}
```

### 閾値の調整
```lua
-- より敏感な検出の場合
CPU_THRESHOLD_ACTIVE = 2.0

-- より長いアイドル時間の場合
HUMAN_IDLE_THRESHOLD = 600  -- 10分
```

## 🚨 トラブルシューティング

### Claude検出されない場合
```bash
# プロセス名を確認
ps aux | grep claude

# WezTerm設定を再読み込み
# F5キーを押すかWezTermを再起動
```

### CPU監視が動作しない場合
```bash
# psコマンドが利用可能か確認
ps -p $$ -o %cpu=

# macOS以外の場合はコマンドを調整が必要な場合あり
```

### 通知音が再生されない場合
```bash
# macOSでの音声ファイル確認
ls -la ~/.claude/perfect.mp3

# システムサウンド確認
afplay /System/Library/Sounds/Ping.aiff
```

## 📈 パフォーマンス考慮事項

### 最適化機能
1. **CPUモニタリングキャッシュ**: 2秒間結果をキャッシュ
2. **効率的なプロセス検索**: 必要時のみps実行
3. **自動クリーンアップ**: 古いキャッシュエントリを削除

### リソース使用量
- **CPU影響**: 最小限（0.25秒間隔での軽量チェック）
- **メモリ使用量**: 軽微（キャッシュデータは小容量）
- **ネットワーク**: 影響なし（ローカル監視のみ）

## 🔄 アップデート履歴

### v2.0.0 (2024-07-01)
- ✅ 強化されたClaude監視システム
- ✅ 人間活動追跡機能
- ✅ CPU使用率ベースの状態検出
- ✅ パフォーマンス最適化
- ✅ 通知システム改善

---

**効率的なClaude開発環境をお楽しみください！ 🚀**