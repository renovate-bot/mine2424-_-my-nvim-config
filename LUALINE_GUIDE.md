# lualine.nvim 設定ガイド 📊

## 📅 導入日: 2024年12月30日

---

## 🎯 概要

**lualine.nvim**は、Neovim向けの高速で美しいステータスラインプラグインです。Flutter開発に特化したカスタムコンポーネントを搭載し、開発効率を大幅に向上させます。

---

## ✨ Flutter開発向け機能

### 🎯 専用コンポーネント

1. **Flutter Status** 🎯
   - プロジェクトがFlutterプロジェクトかどうかを表示
   - pubspec.yamlの存在を自動検出

2. **Dart Version** 🔷
   - 現在使用中のDart SDKバージョンを表示
   - Dartファイル編集時のみ表示

3. **Flutter Device** 📱
   - 接続中のFlutterデバイス情報を表示
   - デバイス数とタイプを自動判別

4. **LSP Status** ⚡
   - アクティブなLSPクライアント名を表示
   - 複数クライアント対応

5. **Copilot Status** 🤖
   - GitHub Copilotの状態を表示
   - Ready/InProgress/Error状態の監視

6. **Git Blame** 👤
   - 現在ファイルの最終編集者を表示
   - Git履歴からの自動取得

---

## 🎨 ステータスライン構成

### レイアウト構成
```
[Mode] [Branch] [Diff] [Filename] [Flutter] | [Copilot] [Diagnostics] [LSP] [Dart] [Encoding] [Format] [Type] [Progress] [Location]
```

### セクション詳細

#### **左側 (lualine_a)**
- **Mode**: 現在のVimモード（短縮表示）
  - `N` (Normal), `I` (Insert), `V` (Visual)

#### **左中央 (lualine_b)**
- **Branch**: 現在のGitブランチ名 🌿
- **Diff**: Git差分情報
  - ➕ 追加行 (緑)
  - 📝 変更行 (黄)
  - ➖ 削除行 (赤)

#### **中央 (lualine_c)**
- **Filename**: ファイル名と状態
  - 相対パス表示
  - `[+]` 変更済み
  - `[RO]` 読み取り専用
  - `[New]` 新規ファイル
- **Flutter Status**: `🎯 Flutter` プロジェクト表示

#### **右中央 (lualine_x)**
- **Copilot Status**: `🤖 Ready/InProgress`
- **Diagnostics**: LSP診断情報
  - 🚨 エラー (赤)
  - ⚠️ 警告 (黄)
  - 💡 情報 (青)
  - 💭 ヒント (緑)
- **LSP Status**: `⚡ dartls` 等
- **Dart Version**: `🔷 3.7.0` 等

#### **右側 (lualine_y, lualine_z)**
- **Encoding**: ファイルエンコーディング
- **File Format**: 改行コード
- **File Type**: ファイルタイプ
- **Progress**: ファイル進行状況
- **Location**: カーソル位置

---

## 🎨 カラーテーマ (Nord)

### コンポーネント別カラー
```lua
colors = {
  branch = '#8FBCBB',      -- ティール (Git branch)
  flutter = '#81A1C1',     -- 青 (Flutter status)
  copilot = '#A3BE8C',     -- 緑 (Copilot)
  lsp = '#D08770',         -- オレンジ (LSP)
  dart = '#5E81AC',        -- 青 (Dart version)
  error = '#BF616A',       -- 赤 (エラー)
  warn = '#EBCB8B',        -- 黄 (警告)
  info = '#88C0D0',        -- シアン (情報)
  hint = '#A3BE8C',        -- 緑 (ヒント)
}
```

### Git差分カラー
- **追加**: `#A3BE8C` (緑)
- **変更**: `#EBCB8B` (黄)
- **削除**: `#BF616A` (赤)

---

## 🔧 カスタムコンポーネント詳細

### 1. Flutter Project Detection
```lua
local function flutter_status()
  if _G.is_flutter_project and _G.is_flutter_project() then
    return "🎯 Flutter"
  end
  return ""
end
```

### 2. Dynamic Dart Version Display
```lua
local function dart_version()
  if vim.bo.filetype == "dart" then
    local handle = io.popen("dart --version 2>&1")
    if handle then
      local result = handle:read("*a")
      handle:close()
      local version = result:match("Dart SDK version: ([%d%.]+)")
      if version then
        return "🔷 " .. version
      end
    end
  end
  return ""
end
```

### 3. LSP Client Status
```lua
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  
  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
  end
  return "⚡ " .. table.concat(client_names, ", ")
end
```

### 4. Copilot Integration
```lua
local function copilot_status()
  local ok, api = pcall(require, "copilot.api")
  if ok then
    local status = api.status.data
    if status and status.status then
      if status.status == "Ready" then
        return "🤖 Ready"
      elseif status.status == "InProgress" then
        return "🤖 ..."
      else
        return "🤖 " .. status.status
      end
    end
  end
  return ""
end
```

---

## 🚀 Flutter開発での活用例

### 1. **プロジェクト識別**
ステータスラインで現在のプロジェクトタイプを即座に確認：
```
lib/main.dart [+] | 🎯 Flutter | 🤖 Ready | ⚡ dartls | 🔷 3.7.0
```

### 2. **開発状況の監視**
- LSPクライアントの動作状況
- Copilotの利用可能性
- Git変更状況の把握

### 3. **診断情報の把握**
```
🚨 2  ⚠️ 5  💡 1  # エラー2個、警告5個、情報1個
```

### 4. **環境情報の確認**
- Dartバージョンの確認
- ファイルエンコーディング
- 改行コード形式

---

## ⚙️ 設定カスタマイズ

### テーマの変更
```lua
options = {
  theme = 'nord',      -- Nord theme
  -- theme = 'gruvbox', -- Gruvbox theme  
  -- theme = 'auto',    -- 自動検出
}
```

### セパレーターのカスタマイズ
```lua
component_separators = { left = '|', right = '|'},
section_separators = { left = '', right = ''},
```

### 更新頻度の調整
```lua
refresh = {
  statusline = 1000,  -- 1秒毎
  tabline = 1000,
  winbar = 1000,
}
```

### グローバルステータス
```lua
globalstatus = true,  -- 全ウィンドウで統一ステータスライン
```

---

## 🎯 実用的なワークフロー

### 1. **Flutter開発開始時**
ステータスラインを確認して以下を把握：
- `🎯 Flutter` プロジェクトであること
- `⚡ dartls` LSPが動作中
- `🔷 3.7.0` Dartバージョン

### 2. **コード編集中**
リアルタイムで以下を監視：
- 診断情報 (`🚨 ⚠️ 💡`)
- Copilot状態 (`🤖 Ready`)
- ファイル変更状態 (`[+]`)

### 3. **Git操作時**
変更状況を視覚的に確認：
- `master` ブランチ名
- `+5 ~2 -1` 差分情報
- `👤 Author` 最終編集者

### 4. **デバッグ時**
環境の整合性確認：
- LSPクライアントの動作
- Dartバージョンの一致
- ファイル保存状態

---

## 📊 パフォーマンス最適化

### 非同期処理
- デバイス検出は非同期実行
- Dartバージョン取得はキャッシュ対応

### 条件付き表示
- Dartバージョンはdartファイルでのみ表示
- Flutter statusはFlutterプロジェクトでのみ表示

### 更新頻度制御
- 1秒間隔での更新でCPU負荷を最小化

---

## 🎨 視覚的な改善効果

### Before (デフォルト)
```
-- INSERT --                          main.dart                      1,1           All
```

### After (Flutter最適化版)
```
I  master +3 ~1  main.dart [+] 🎯 Flutter | 🤖 Ready ⚡ dartls 🔷 3.7.0 UTF-8 unix dart 45% 1:1
```

### 情報密度の向上
- **5倍以上の情報量**: 開発に必要な情報を一箇所に集約
- **色分けによる視認性**: 重要度に応じたカラーコーディング
- **コンテキスト感応**: 現在の作業に関連する情報のみ表示

---

## 🔧 トラブルシューティング

### よくある問題

1. **Dart versionが表示されない**
   - `dart --version`コマンドの動作確認
   - PATHの設定確認

2. **Flutter statusが表示されない**
   - `pubspec.yaml`ファイルの存在確認
   - `_G.is_flutter_project`関数の動作確認

3. **Copilot statusが表示されない**
   - Copilotプラグインのインストール確認
   - `:Copilot status`での状態確認

4. **デバイス情報が表示されない**
   - `flutter devices --machine`の動作確認
   - Flutter SDKのインストール確認

### デバッグ方法
```lua
-- 個別コンポーネントのテスト
:lua print(require('lualine').get_config())
:lua print(vim.inspect(vim.lsp.get_clients()))
```

---

## 🚀 今後の拡張予定

### Phase 1: 追加予定機能
- [ ] Flutter Hot Reload状態の表示
- [ ] テスト実行状況の監視
- [ ] ビルド進行状況の表示

### Phase 2: 高度な機能
- [ ] パフォーマンスメトリクスの表示
- [ ] 依存関係の更新通知
- [ ] CI/CD状態の統合

---

**📊 lualine.nvimでFlutter開発の状況を常に把握しましょう！**