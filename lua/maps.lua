-- ===============================================
-- キーマップ設定
-- ===============================================
local keymap = vim.keymap

-- リーダーキー設定
vim.g.mapleader = ' '      -- スペースキーをリーダーに設定

-- ===============================================
-- 基本操作
-- ===============================================

-- ESC代替キーマップ
keymap.set('i', 'jj', '<ESC>', { desc = 'Insert mode escape' })
keymap.set('i', 'kk', '<ESC>', { desc = 'Insert mode escape alternative' })

-- 検索ハイライト解除
keymap.set('n', '<ESC><ESC>', ':nohl<Return>', { desc = 'Clear search highlight' })

-- 保存・終了
keymap.set('n', '<Leader>w', ':w<Return>', { desc = 'Save file' })
keymap.set('n', '<Leader>q', ':q<Return>', { desc = 'Quit' })
keymap.set('n', '<Leader>wq', ':wq<Return>', { desc = 'Save and quit' })

-- ===============================================
-- ウィンドウ・タブ操作
-- ===============================================

-- ウィンドウ分割
keymap.set('n', 'ss', ':split<Return><C-w>w', { desc = 'Horizontal split' })
keymap.set('n', 'sv', ':vsplit<Return><C-w>w', { desc = 'Vertical split' })

-- ウィンドウ移動（Tmuxとの連携を考慮）
keymap.set('n', '<Leader><Space>', '<C-w>w', { desc = 'Switch window' })
keymap.set('n', 'sh', '<C-w>h', { desc = 'Move to left window' })
keymap.set('n', 'sk', '<C-w>k', { desc = 'Move to upper window' })
keymap.set('n', 'sj', '<C-w>j', { desc = 'Move to lower window' })
keymap.set('n', 'sl', '<C-w>l', { desc = 'Move to right window' })

-- ウィンドウリサイズ
keymap.set('n', '<C-w><left>', '<C-w><', { desc = 'Decrease window width' })
keymap.set('n', '<C-w><right>', '<C-w>>', { desc = 'Increase window width' })
keymap.set('n', '<C-w><up>', '<C-w>+', { desc = 'Increase window height' })
keymap.set('n', '<C-w><down>', '<C-w>-', { desc = 'Decrease window height' })

-- タブ操作
keymap.set('n', '<Leader>t', ':tabnew<Return>', { desc = 'New tab' })
keymap.set('n', '<Leader>tc', ':tabclose<Return>', { desc = 'Close tab' })
keymap.set('n', '<Tab>', ':tabnext<Return>', { desc = 'Next tab' })
keymap.set('n', '<S-Tab>', ':tabprev<Return>', { desc = 'Previous tab' })

-- ===============================================
-- バッファ操作
-- ===============================================

-- バッファ移動
keymap.set('n', '<Leader>bp', ':bprev<Return>', { desc = 'Previous buffer' })
keymap.set('n', '<Leader>bn', ':bnext<Return>', { desc = 'Next buffer' })
keymap.set('n', '<Leader>bd', ':bdelete<Return>', { desc = 'Delete buffer' })
keymap.set('n', '<Leader>bl', ':buffers<Return>', { desc = 'List buffers' })

-- ===============================================
-- 編集操作
-- ===============================================

-- 行の移動
keymap.set('v', 'J', ":m '>+1<Return>gv=gv", { desc = 'Move selection down' })
keymap.set('v', 'K', ":m '<-2<Return>gv=gv", { desc = 'Move selection up' })

-- インデント調整（ビジュアルモードで選択を保持）
keymap.set('v', '<', '<gv', { desc = 'Decrease indent and keep selection' })
keymap.set('v', '>', '>gv', { desc = 'Increase indent and keep selection' })

-- 行の複製
keymap.set('n', '<Leader>d', ':t.<Return>', { desc = 'Duplicate line' })

-- 全選択
keymap.set('n', '<Leader>a', 'ggVG', { desc = 'Select all' })

-- ===============================================
-- 検索・置換
-- ===============================================

-- 現在の単語を検索
keymap.set('n', '*', '*N', { desc = 'Search current word forward' })
keymap.set('n', '#', '#N', { desc = 'Search current word backward' })

-- 置換（現在の単語）
keymap.set('n', '<Leader>r', ':%s/<C-r><C-w>//g<Left><Left>', { desc = 'Replace current word' })

-- ===============================================
-- ファイル操作
-- ===============================================

-- 新しいファイル
keymap.set('n', '<Leader>n', ':enew<Return>', { desc = 'New file' })

-- ファイル保存（フォーマット付き）
keymap.set('n', '<Leader>wf', ':w<Return>:!prettier --write %<Return>', { desc = 'Save and format' })

-- ===============================================
-- ターミナル
-- ===============================================

-- ターミナルを開く
keymap.set('n', '<Leader>T', ':terminal<Return>', { desc = 'Open terminal' })
keymap.set('t', '<ESC>', '<C-\\><C-n>', { desc = 'Terminal normal mode' })

-- ===============================================
-- ユーティリティ
-- ===============================================

-- 現在のファイルパスをコピー
keymap.set('n', '<Leader>cp', ':let @+ = expand("%:p")<Return>', { desc = 'Copy file path' })

-- 現在の行をコピー
keymap.set('n', '<Leader>cl', ':let @+ = getline(".")<Return>', { desc = 'Copy current line' })

-- ファイル内容を整形
keymap.set('n', '<Leader>f', 'gg=G', { desc = 'Format entire file' })

-- QuickFixリスト
keymap.set('n', '<Leader>co', ':copen<Return>', { desc = 'Open quickfix' })
keymap.set('n', '<Leader>cc', ':cclose<Return>', { desc = 'Close quickfix' })
keymap.set('n', '<Leader>cn', ':cnext<Return>', { desc = 'Next quickfix item' })
keymap.set('n', '<Leader>cp', ':cprev<Return>', { desc = 'Previous quickfix item' })

-- ===============================================
-- Flutter開発専用キーマップ
-- ===============================================

-- Flutter プロジェクト管理
keymap.set('n', '<Leader>Fr', ':!flutter run<Return>', { desc = 'Flutter run' })
keymap.set('n', '<Leader>Fh', ':!flutter run --hot-reload<Return>', { desc = 'Flutter hot reload' })
keymap.set('n', '<Leader>Fc', ':!flutter clean<Return>', { desc = 'Flutter clean' })
keymap.set('n', '<Leader>Fb', ':!flutter build apk<Return>', { desc = 'Flutter build APK' })
keymap.set('n', '<Leader>Ft', ':!flutter test<Return>', { desc = 'Flutter test' })
keymap.set('n', '<Leader>Fd', ':!flutter devices<Return>', { desc = 'Flutter devices' })
keymap.set('n', '<Leader>Fe', ':!flutter emulators<Return>', { desc = 'Flutter emulators' })

-- Dart分析・フォーマット
keymap.set('n', '<Leader>Da', ':!dart analyze<Return>', { desc = 'Dart analyze' })
keymap.set('n', '<Leader>Df', ':!dart format .<Return>', { desc = 'Dart format' })
keymap.set('n', '<Leader>Dp', ':!dart pub get<Return>', { desc = 'Dart pub get' })
keymap.set('n', '<Leader>Du', ':!dart pub upgrade<Return>', { desc = 'Dart pub upgrade' })

-- Flutter開発用ターミナル
keymap.set('n', '<Leader>FT', ':tabnew | terminal flutter run<Return>', { desc = 'Flutter run in new tab' })
keymap.set('n', '<Leader>FL', ':split | terminal flutter logs<Return>', { desc = 'Flutter logs in split' })

-- ===============================================
-- IDE風レイアウト
-- ===============================================

-- IDE風レイアウト起動
keymap.set('n', '<Leader>ide', ':StartSmartIDE<Return>', { desc = 'Start smart IDE layout' })
keymap.set('n', '<Leader>I', ':StartIDE<Return>', { desc = 'Start full IDE layout' })
keymap.set('n', '<Leader>is', ':StartSimpleIDE<Return>', { desc = 'Start simple IDE layout' })
keymap.set('n', '<Leader>if', ':StartFlutterIDE<Return>', { desc = 'Start Flutter IDE layout' })
keymap.set('n', '<Leader>ir', ':ResetLayout<Return>', { desc = 'Reset window layout' })

-- ファイルツリー操作
keymap.set('n', '<Leader>e', ':Lexplore<Return>', { desc = 'Toggle file explorer' })
keymap.set('n', '<Leader>E', ':Explore<Return>', { desc = 'Open file explorer in current window' })
