# VSCode統合機能 アップデート 🚀

## 📅 更新日: 2024年12月30日

---

## 🎯 概要

この更新では、Neovim設定にVSCodeの`launch.json`統合機能の改善と最適化を実施しました。既存の機能を維持しつつ、コードの重複を削除し、エラーハンドリングを強化しました。

---

## ✅ 実装済み機能の確認

### 🔍 VSCode launch.json 統合機能

**既に実装されている機能:**
- ✅ `require("dap.ext.vscode").load_launchjs()` の使用
- ✅ プロジェクトルートの自動検出
- ✅ 複数言語サポート（Dart、Flutter、Node.js、Python、Go、Rust、C++、Java）
- ✅ launch.json変更時の自動再読み込み
- ✅ 手動再読み込み機能（`<leader>dl`）
- ✅ 設定選択機能（`<leader>vl`）
- ✅ mise/asdf版本管理ツールとの統合

---

## 🔧 今回の改善内容

### 1. **コード重複の解消**

**問題点:**
- `find_project_root()`関数が複数箇所で重複定義されていた
- launch.json読み込みロジックが散在していた

**解決策:**
- 重複する関数定義を統合
- 共通の`load_launch_json()`関数を作成
- エラーハンドリングを一元化

**改善箇所:**
```lua
-- 統合前: 複数の重複関数
local function find_project_root() -- 複数箇所に存在

-- 統合後: 一つの統合関数
local function find_project_root()  -- DAP設定内に一元化
local function load_launch_json(path) -- エラーハンドリング付き
```

### 2. **エラーハンドリングの強化**

**追加された機能:**
- 不正なlaunch.jsonファイルの検出
- エラー発生時の適切な通知
- 失敗時のgracefulな処理

**実装例:**
```lua
local function load_launch_json(path)
  if path then
    local success, error = pcall(require('dap.ext.vscode').load_launchjs, path, launch_json_type_map)
    if not success then
      vim.notify("Failed to load launch.json: " .. tostring(error), vim.log.levels.ERROR)
      return false
    end
    return true
  end
  return false
end
```

### 3. **設定管理の最適化**

**改善点:**
- 言語タイプマッピングの一元化
- 設定再読み込みロジックの簡素化
- より堅牢なプロジェクト検出

**最適化されたタイプマッピング:**
```lua
local launch_json_type_map = {
  dart = {'dart', 'flutter'},
  flutter = {'dart', 'flutter'},
  node = {'javascript', 'typescript'},
  python = {'python'},
  go = {'go'},
  rust = {'rust'},
  cpp = {'cpp', 'c'},
  java = {'java'}
}
```

---

## 🎮 使用方法

### 基本的な使用フロー

1. **プロジェクトにlaunch.jsonを作成**
   ```bash
   mkdir -p .vscode
   ```

2. **launch.json設定例**
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "name": "Launch Flutter",
         "type": "dart",
         "request": "launch",
         "program": "lib/main.dart"
       },
       {
         "name": "Launch Dart Script",
         "type": "dart", 
         "request": "launch",
         "program": "${file}"
       }
     ]
   }
   ```

3. **Neovimでのデバッグ実行**
   ```
   <leader>vl    # 設定を選択してデバッグ実行
   <leader>dl    # 設定を手動再読み込み
   <F5>          # デバッグ開始/継続
   ```

### 高度な使用例

**複数環境対応のlaunch.json:**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Debug",
      "type": "dart",
      "request": "launch", 
      "program": "lib/main.dart",
      "args": ["--debug"]
    },
    {
      "name": "Flutter Profile",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--profile"]
    },
    {
      "name": "Flutter Release",
      "type": "dart", 
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--release"]
    }
  ]
}
```

---

## 🔧 技術詳細

### アーキテクチャの改善

**統合前:**
```
┌─ find_project_root() [重複1]
├─ find_launch_json() 
├─ load_launchjs() [散在]
└─ find_project_root() [重複2]
```

**統合後:**
```
┌─ find_project_root() [統合]
├─ find_launch_json() [改善]
├─ load_launch_json() [エラーハンドリング]
└─ launch_json_type_map [一元化]
```

### ファイル構造

```
lua/flutter-dev-with-dap.lua
├─ Project root detection (lines 610-640)
├─ Launch.json loading (lines 642-674) 
├─ DAP configuration (lines 681-795)
├─ Debug keymaps (lines 818-838)
├─ Auto-reload watcher (lines 841-858)
└─ Configuration selector (lines 1082-1225)
```

---

## 🎯 今後の予定

### Phase 1: 完了 ✅
- [x] VSCode launch.json統合の実装確認
- [x] コード重複の解消
- [x] エラーハンドリングの強化
- [x] ドキュメントの更新

### Phase 2: 将来の拡張案 📋
- [ ] tasks.json統合の同様な最適化
- [ ] デバッグ設定のテンプレート機能
- [ ] プロジェクト固有の設定管理UI
- [ ] launch.json作成ウィザード

---

## 📚 関連ドキュメント

- [FLUTTER_WORKFLOW.md](./FLUTTER_WORKFLOW.md) - デバッグワークフローの詳細
- [FLUTTER_KEYBINDINGS.md](./FLUTTER_KEYBINDINGS.md) - キーバインド一覧
- [lua/flutter-dev-with-dap.lua](./lua/flutter-dev-with-dap.lua) - 実装ファイル

---

## 💡 よくある質問

### Q: 既存のプロジェクトで動作しない場合は？

**A:** 以下の手順で確認してください：

1. プロジェクトルートの確認
   ```bash
   pwd  # プロジェクトルートにいることを確認
   ls .vscode/launch.json  # ファイルの存在確認
   ```

2. 設定の再読み込み
   ```
   <leader>dl  # 手動で再読み込み
   ```

3. エラーログの確認
   - Neovimの通知メッセージを確認
   - `:messages`でエラーログを表示

### Q: 新しい言語を追加したい場合は？

**A:** `launch_json_type_map`に追加してください：

```lua
local launch_json_type_map = {
  -- 既存の設定...
  your_language = {'your_filetype1', 'your_filetype2'}
}
```

### Q: mise/asdfが正しく検出されない場合は？

**A:** 以下を確認してください：

```bash
# mise/asdfコマンドが利用可能か確認
which mise
which asdf

# Dart/Flutter SDKが正しくインストールされているか確認  
mise which dart
mise which flutter
```

---

**🎉 これでVSCode launch.json統合機能の最適化が完了しました！効率的なデバッグ環境をお楽しみください。**