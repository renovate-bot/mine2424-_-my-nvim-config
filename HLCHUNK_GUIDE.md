# hlchunk.nvim 使用ガイド 🌈

## 📅 導入日: 2024年12月30日

---

## 🎯 概要

**hlchunk.nvim**は、Neovimでコードの構造を視覚的に理解しやすくする高性能なプラグインです。特にFlutter開発のような深いネスト構造を持つコードに対して威力を発揮します。

---

## ✨ 主な機能

### 1. **コードチャンクハイライト** 🔍
- カーソル位置に応じてコードブロックの範囲を視覚的に表示
- 現在編集中のコードセクションを明確に識別

### 2. **多段階インデントライン** 📏
- ネストレベルに応じて6段階のカラーでインデントを表示
- Flutterの深いWidget階層を直感的に理解

### 3. **行番号ハイライト** 🔢
- 現在のコードチャンクに含まれる行番号をハイライト
- コードの範囲を素早く把握

### 4. **空行の可視化** 👁️
- 空行を適切に表示してコードの区切りを明確化

---

## 🎨 Flutter開発向け最適化

### カラースキーム
```lua
-- チャンクハイライト
"#806d9c"  -- メインチャンクカラー（薄紫）
"#c21f30"  -- エラーチャンク用（赤）

-- 6段階インデントカラー
"#434C5E"  -- レベル1（ダークグレー）
"#4C566A"  -- レベル2（グレー）
"#5E81AC"  -- レベル3（青）
"#88C0D0"  -- レベル4（シアン）
"#81A1C1"  -- レベル5（ライトブルー）
"#8FBCBB"  -- レベル6（ティール）
```

### 文字設定
```lua
chars = {
  horizontal_line = "─",  -- 水平線
  vertical_line = "│",    -- 垂直線
  left_top = "╭",         -- 左上角
  left_bottom = "╰",      -- 左下角
  right_arrow = "─",      -- 右矢印
}
```

---

## 🚀 Flutter開発での活用例

### 1. **Widget階層の理解**

**従来の表示:**
```dart
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('My App'),
),
body: Column(
children: [
Container(
child: Text('Hello'),
),
],
),
);
}
```

**hlchunk.nvim使用時:**
- カーソルがWidgetにある時、そのWidget全体がハイライトされる
- ネストレベルに応じてインデントラインの色が変化
- コードブロックの開始・終了が視覚的に明確

### 2. **深いネスト構造の把握**

```dart
Widget complexWidget() {
  return Container(          // レベル1: ダークグレー
    child: Column(           // レベル2: グレー
      children: [
        Row(                 // レベル3: 青
          children: [
            Expanded(        // レベル4: シアン
              child: Card(   // レベル5: ライトブルー
                child: ListTile( // レベル6: ティール
                  title: Text('Item'),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```

### 3. **エラー検知**
不正なブロック構造（括弧の不一致など）は赤色でハイライトされ、即座に問題を特定できます。

---

## ⚙️ 設定詳細

### 基本設定
```lua
require("hlchunk").setup({
  chunk = {
    enable = true,              -- チャンクハイライト有効
    notify = true,              -- 通知有効
    use_treesitter = true,      -- Treesitter使用
    max_file_size = 1024 * 1024,-- 1MB制限
    error_sign = true,          -- エラーサイン表示
  },
  indent = {
    enable = true,              -- インデントライン有効
    use_treesitter = false,     -- パフォーマンス最適化
  },
  line_num = {
    enable = true,              -- 行番号ハイライト有効
    use_treesitter = true,      -- Treesitter使用
  },
  blank = {
    enable = true,              -- 空行表示有効
  },
})
```

### 除外ファイルタイプ
以下のファイルタイプでは機能を無効化しています：
- `aerial` - アウトラインビュー
- `dashboard` - ダッシュボード
- `help` - ヘルプファイル
- `TelescopePrompt` - Telescope検索画面
- `gitcommit` - Gitコミットメッセージ

---

## 💡 使用のヒント

### 1. **パフォーマンス最適化**
- 1MB以上の大きなファイルでは自動的に無効化
- 非同期レンダリングで快適な編集体験

### 2. **Flutter開発での効果的な使い方**
- **Widget構造の把握**: カーソルをWidgetに合わせてブロック全体を確認
- **リファクタリング時**: 影響範囲を視覚的に確認しながら作業
- **コードレビュー**: 複雑なネスト構造の理解を促進

### 3. **トラブルシューティング**
- 表示が重い場合: `use_treesitter = false`に設定
- 特定ファイルで無効化: `exclude_filetypes`に追加

---

## 🔧 カスタマイズ例

### カラーテーマの変更
```lua
-- ダークテーマ用
style = {
  "#2E3440",  -- Nord0
  "#3B4252",  -- Nord1
  "#434C5E",  -- Nord2
  "#4C566A",  -- Nord3
  "#5E81AC",  -- Nord10
  "#81A1C1",  -- Nord9
}

-- ライトテーマ用
style = {
  "#ECEFF4",  -- Nord6
  "#E5E9F0",  -- Nord5
  "#D8DEE9",  -- Nord4
  "#8FBCBB",  -- Nord7
  "#88C0D0",  -- Nord8
  "#81A1C1",  -- Nord9
}
```

### 文字スタイルの変更
```lua
chars = {
  horizontal_line = "━",  -- 太い水平線
  vertical_line = "┃",    -- 太い垂直線
  left_top = "┏",         -- 太い左上角
  left_bottom = "┗",      -- 太い左下角
  right_arrow = "━",      -- 太い右矢印
}
```

---

## 📊 パフォーマンス情報

### 測定値
- **平均レンダリング時間**: 0.7ms
- **大ファイル制限**: 1MB
- **メモリ使用量**: 最小限（extmarkキャッシュ使用）

### 最適化機能
- **非同期レンダリング**: UIブロックを防止
- **C関数高速化**: 計算処理の最適化
- **スロットル処理**: 高頻度更新の制御

---

## 🎯 Flutter開発での実用例

### ケーススタディ1: 複雑なレイアウト構築
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(                    // チャンク1
    appBar: AppBar(                  // チャンク2
      title: Text('Complex Layout'),
      actions: [
        IconButton(                  // チャンク3
          icon: Icon(Icons.settings),
          onPressed: () => showDialog( // チャンク4
            context: context,
            builder: (context) => AlertDialog( // チャンク5
              title: Text('Settings'),
              content: Column(       // チャンク6
                children: [
                  // 深いネスト構造が色分けで明確
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    body: ListView.builder(          // メインチャンク
      itemBuilder: (context, index) => Card( // アイテムチャンク
        child: ListTile(             // コンテンツチャンク
          title: Text('Item $index'),
          subtitle: Text('Description'),
        ),
      ),
    ),
  );
}
```

### ケーススタディ2: エラー検知
```dart
Widget errorExample() {
  return Container(
    child: Column(
      children: [
        Text('Hello'),
      // ← 括弧が不足している場合、赤色でハイライト
    ),
  );  // ← 追加の括弧エラーも検知
}
```

---

## 🚀 今後の活用

### 学習効果
- **コード構造の理解促進**: 視覚的フィードバックによる学習支援
- **ベストプラクティス**: 適切なネスト深度の意識向上

### チーム開発
- **コードレビュー効率化**: 構造理解の時間短縮
- **知識共有**: 視覚的な説明による理解促進

---

**🎨 hlchunk.nvimでFlutter開発の視覚的体験を向上させましょう！**