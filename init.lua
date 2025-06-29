-- Neovim設定
require('base')
require('maps')
require('plugins')

-- IDE風レイアウト設定
require('ide-layout').setup()

-- Flutter開発環境設定
-- DAP機能なし版（安定版）
require('flutter-dev-minimal')

-- DAP機能付き版を使用したい場合は、上記をコメントアウトして以下を有効にしてください
-- require('flutter-dev-with-dap')
