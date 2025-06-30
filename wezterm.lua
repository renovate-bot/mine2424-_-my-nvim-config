local wezterm = require 'wezterm'

-- ===============================================
-- OS Detection System
-- ===============================================
local os = (function()
  if string.find(wezterm.target_triple, 'apple') then
    return 'macOS'
  elseif string.find(wezterm.target_triple, 'windows') then
    return 'windows'
  elseif string.find(wezterm.target_triple, 'linux') then
    return 'linux'
  end
end)()

-- ===============================================
-- Configuration Builder
-- ===============================================
local config = wezterm.config_builder()

-- ===============================================
-- Claude監視・Git表示用定数
-- ===============================================
local CLAUDE_CONSTANTS = {
  -- プロセスフィルタリング
  EXCLUDE_PATTERNS = { 'npm', 'node' },
  INVALID_TTY = '??',

  -- 実行判定の閾値
  CPU_ACTIVE_THRESHOLD = 1.0, -- CPU使用率がこれ以上なら実行中
  CPU_CHECK_THRESHOLD = 0.1, -- FDチェックを行う最小CPU使用率
  FD_ACTIVE_THRESHOLD = 15, -- ファイルディスクリプタ数の閾値

  -- 表示アイコン・色彩
  EMOJI_IDLE = '🤖',
  EMOJI_RUNNING = '⚡',
  COLOR_ICON = '#FF6B6B',
  
  -- Git表示色
  GIT_ICON_COLOR = '#569CD6',
  GIT_REPO_COLOR = '#808080',
  GIT_BRANCH_ICON_COLOR = '#4EC9B0',
  GIT_BRANCH_COLOR = '#909090',

  -- スペーシング
  SPACING_SMALL = '  ',
  SPACING_MEDIUM = '   ',
  SPACING_SINGLE = ' ',

  -- システムコマンド
  PS_PATH = os == 'macOS' and '/bin/ps' or '/usr/bin/ps',
}

-- ===============================================
-- Performance Optimizations (OS-specific)
-- ===============================================
config.animation_fps = 120
config.max_fps = 120
config.prefer_egl = true
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'

-- ===============================================
-- Basic Configuration
-- ===============================================

-- Font Configuration with Nerd Fonts support
config.font = wezterm.font_with_fallback {
  -- Nerd Fonts (with icon support)
  'JetBrainsMono Nerd Font',
  'FiraCode Nerd Font',
  'Hack Nerd Font',
  'CascadiaCode Nerd Font',
  'MesloLGS Nerd Font',
  'Inconsolata Nerd Font',
  
  -- Fallback to regular fonts
  'JetBrains Mono',
  'Fira Code',
  'Hack',
  'SF Mono',
  'Menlo',
  'Monaco',
  'Cascadia Code',
  'DejaVu Sans Mono',
  'Courier New',
}

-- OS-specific font sizing
if os == 'macOS' or os == 'linux' then
  config.font_size = 13.0
  config.initial_cols = 140
  config.initial_rows = 40
elseif os == 'windows' then
  config.font_size = 12.0
  config.initial_cols = 120
  config.initial_rows = 35
end

config.line_height = 1.2

-- Color scheme (Solarized Dark for tmux/nvim consistency)
config.color_scheme = 'Solarized Dark'

-- Enhanced color scheme for better tab visibility
config.colors = {
  tab_bar = {
    background = '#1a202c',
    active_tab = {
      bg_color = '#3182ce',
      fg_color = '#ffffff',
      intensity = 'Bold',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    inactive_tab = {
      bg_color = '#2d3748',
      fg_color = '#e2e8f0',
      intensity = 'Normal',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    inactive_tab_hover = {
      bg_color = '#4a5568',
      fg_color = '#ffffff',
      intensity = 'Normal',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    new_tab = {
      bg_color = '#1a202c',
      fg_color = '#68d391',
      intensity = 'Bold',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    new_tab_hover = {
      bg_color = '#2d3748',
      fg_color = '#68d391',
      intensity = 'Bold',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
  },
}

-- Window appearance
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.95
config.text_background_opacity = 1.0
config.macos_window_background_blur = 30

-- Enhanced Tab bar configuration
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false  -- 上部に移動してより見やすく
config.show_tab_index_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = true
config.tab_max_width = 32
config.hide_tab_bar_if_only_one_tab = false

-- Scrollback
config.scrollback_lines = 10000

-- ===============================================
-- Claude Process Monitoring Functions
-- ===============================================

-- プロセスの実行状態をチェックするヘルパー関数
local function check_process_running(pid)
  local ps_success, ps_stdout = wezterm.run_child_process {
    CLAUDE_CONSTANTS.PS_PATH,
    '-p',
    tostring(pid),
    '-o',
    'stat,pcpu,rss',
  }

  if not ps_success or not ps_stdout then
    return false
  end

  local lines = {}
  for line in ps_stdout:gmatch '[^\n]+' do
    table.insert(lines, line)
  end

  if #lines < 2 then
    return false
  end

  local data_line = lines[2]
  local stat, pcpu, rss = data_line:match '%s*(%S+)%s+(%S+)%s+(%S+)'

  if not stat then
    return false
  end

  -- 1. プロセス状態による判定
  if stat:match '^[RD]' then
    return true
  end

  local cpu_usage = tonumber(pcpu) or 0

  -- 2. CPU使用率による判定
  if cpu_usage >= CLAUDE_CONSTANTS.CPU_ACTIVE_THRESHOLD then
    return true
  end

  -- 3. ファイルディスクリプタ数をチェック（コスト高いので条件付き）
  if cpu_usage > CLAUDE_CONSTANTS.CPU_CHECK_THRESHOLD then
    local lsof_success, lsof_stdout = wezterm.run_child_process {
      'lsof',
      '-p',
      tostring(pid),
      '-t',
    }
    if lsof_success and lsof_stdout then
      local fd_count = 0
      for _ in lsof_stdout:gmatch '[^\n]+' do
        fd_count = fd_count + 1
      end
      if fd_count > CLAUDE_CONSTANTS.FD_ACTIVE_THRESHOLD then
        return true
      end
    end
  end

  return false
end

-- Claude プロセス情報を取得する関数
local function get_claude_status(window)
  -- エラーハンドリング
  if not window then
    return { tab_sessions = {} }
  end

  local success, result = pcall(function()
    local mux_window = window:mux_window()
    if not mux_window then
      return { tab_sessions = {} }
    end

    local tabs = mux_window:tabs()
    if not tabs then
      return { tab_sessions = {} }
    end

    local tab_sessions = {}

    for tab_index, tab in ipairs(tabs) do
      local has_claude = false
      local is_running = false

      -- タブ内の全ペインをチェック
      local tab_success, panes = pcall(function() return tab:panes() end)
      if tab_success and panes then
        for _, pane in ipairs(panes) do
          local proc_success, proc_info = pcall(function() return pane:get_foreground_process_info() end)
          if proc_success and proc_info then
            -- Claudeプロセスかチェック（プロセス名またはargvで）
            local is_claude_process = false
            if proc_info.name then
              if proc_info.name:match('claude') or 
                 proc_info.name:match('Claude') or
                 proc_info.name:match('claude%-code') or
                 proc_info.name:match('claude_code') then
                is_claude_process = true
              end
            end
            
            if not is_claude_process and proc_info.argv and #proc_info.argv > 0 then
              for _, arg in ipairs(proc_info.argv) do
                if arg:match('claude') or 
                   arg:match('Claude') or
                   arg:match('claude%-code') or
                   arg:match('claude_code') or
                   arg:match('/claude') then
                  is_claude_process = true
                  break
                end
              end
            end
            
            if is_claude_process then
              -- 除外パターンをチェック
              local should_exclude = false
              local cmdline = table.concat(proc_info.argv or {}, ' ')
              for _, pattern in ipairs(CLAUDE_CONSTANTS.EXCLUDE_PATTERNS) do
                if cmdline:match(pattern) then
                  should_exclude = true
                  break
                end
              end

              if not should_exclude then
                has_claude = true
                -- 実行状態をチェック
                if proc_info.pid then
                  is_running = check_process_running(proc_info.pid)
                end
                break -- タブ内に1つでもClaudeがあれば十分
              end
            end
          end
        end
      end

      -- タブごとのClaude情報を記録
      table.insert(tab_sessions, {
        tab_index = tab_index,
        has_claude = has_claude,
        running = is_running
      })
    end

    return { tab_sessions = tab_sessions }
  end)

  if success then
    return result
  else
    -- エラー時は空のセッションを返す
    return { tab_sessions = {} }
  end
end

-- ===============================================
-- Git Information Functions
-- ===============================================

-- Git コマンドを安全に実行するヘルパー関数
local function safe_git_command(cwd, ...)
  local success, stdout = wezterm.run_child_process {
    'git',
    '-C',
    cwd,
    ...,
  }
  if success then
    return stdout:gsub('\n', '')
  end
  return nil
end

-- Git URL からリポジトリ名を抽出
local function extract_repo_name_from_url(url)
  if not url then
    return nil
  end

  -- パターンマッチング
  -- https://github.com/USER/repo.git → repo
  -- git@github.com:USER/repo.git → repo
  local repo_name = url:match('([^/]+)%.git$') or url:match('([^/]+)$')

  return repo_name
end

-- Git情報を取得する関数
local function get_git_info(cwd_path)
  if not cwd_path then
    return nil
  end

  -- Git リポジトリかチェック
  if not safe_git_command(cwd_path, 'rev-parse', '--git-dir') then
    return nil
  end

  -- リポジトリ名を取得（優先順位）
  local repo_name = nil

  -- 方法1: remote origin の URL から取得
  local remote_url = safe_git_command(cwd_path, 'config', '--get', 'remote.origin.url')
  if remote_url then
    repo_name = extract_repo_name_from_url(remote_url)
  end

  -- 方法2: 他の remote から取得
  if not repo_name then
    local remotes = safe_git_command(cwd_path, 'remote')
    if remotes and remotes ~= '' then
      -- 最初の remote を使用
      local first_remote = remotes:match('([^\n]+)')
      if first_remote then
        remote_url = safe_git_command(cwd_path, 'config', '--get', 'remote.' .. first_remote .. '.url')
        if remote_url then
          repo_name = extract_repo_name_from_url(remote_url)
        end
      end
    end
  end

  -- 方法3: toplevel のディレクトリ名（通常のリポジトリ）
  if not repo_name then
    local toplevel = safe_git_command(cwd_path, 'rev-parse', '--show-toplevel')
    if toplevel then
      -- worktree の場合、.bare や .git を含む親ディレクトリを探す
      local bare_pattern = '([^/]+)%.bare'
      local git_pattern = '([^/]+)%.git'
      local dir_pattern = '([^/]+)$'

      if toplevel:match('%.bare/') or toplevel:match('%.git/') then
        -- パスから bareリポジトリ名を抽出
        repo_name = toplevel:match(bare_pattern) or toplevel:match(git_pattern)
      else
        -- 通常のリポジトリ
        repo_name = toplevel:match(dir_pattern)
      end
    end
  end

  -- 方法4: 現在のディレクトリ名（最終手段）
  if not repo_name then
    local dir_name = cwd_path:match('([^/]+)$')
    -- .git 拡張子を削除
    repo_name = dir_name:gsub('%.git$', '')
  end

  -- ブランチ名を取得
  local branch = safe_git_command(cwd_path, 'branch', '--show-current')
  if not branch or branch == '' then
    local ref = safe_git_command(cwd_path, 'symbolic-ref', '--short', 'HEAD')
    if ref then
      branch = ref
    else
      branch = safe_git_command(cwd_path, 'rev-parse', '--short', 'HEAD')
    end
  end

  return {
    repo_name = repo_name,
    branch = branch
  }
end

-- ===============================================
-- tmux Integration & Key Bindings
-- ===============================================

-- Disable default WezTerm key bindings that conflict with tmux
config.disable_default_key_bindings = false

-- ===============================================
-- Development Enhancement Features
-- ===============================================

-- Leader key configuration
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }


-- ベルイベントを捕捉する
config.audible_bell = 'Disabled'
wezterm.on('bell', function(window, pane)
  local proc_info = pane:get_foreground_process_info()
  if not proc_info or not proc_info.argv then
    return
  end
  local cmdline = table.concat(proc_info.argv, ' ')

  if string.find(cmdline, 'claude') then
    -- Claude タスクが完了したときの処理
    local sound_file = wezterm.home_dir .. '/.claude/perfect.mp3'
    if os == 'macOS' then
      wezterm.background_child_process { 'afplay', sound_file }
    elseif os == 'linux' then
      wezterm.background_child_process { 'aplay', sound_file }
    end
    -- ウィンドウに通知を表示
    local process_name = proc_info.name or 'プロセス'
    window:toast_notification('Claude タスク完了', process_name .. ' が完了しました', nil, 3000)
  else
    -- その他のプロセスのベルイベント
    if os == 'macOS' then
      -- macOS の場合、デフォルトのサウンドを鳴らす
      wezterm.background_child_process { 'afplay', '/System/Library/Sounds/Tink.aiff' }
    elseif os == 'linux' then
      wezterm.background_child_process { 'aplay', '/usr/share/sounds/freedesktop/stereo/bell.oga' }
    end
  end
end)


-- Enhanced key bindings with Leader and development features
config.keys = {
  -- ===============================================
  -- Leader-based tmux-style bindings
  -- ===============================================
  -- Window management
  { key = 'n', mods = 'SHIFT|CTRL', action = wezterm.action.ToggleFullScreen },
  { key = 'Enter', mods = 'ALT', action = wezterm.action.DisableDefaultAssignment },
  
  -- Pane operations (Leader-based) - disabled for single pane mode
  { key = 'c', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },

  -- ===============================================
  -- Legacy SHIFT+CTRL bindings (for compatibility)
  -- ===============================================

  -- Tab management
  {
    key = 't',
    mods = 'CMD',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },


  -- Font size adjustment
  {
    key = '=',
    mods = 'CMD',
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = '-',
    mods = 'CMD',
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key = '0',
    mods = 'CMD',
    action = wezterm.action.ResetFontSize,
  },

  -- Copy/Paste
  {
    key = 'c',
    mods = 'CMD',
    action = wezterm.action.CopyTo 'Clipboard',
  },
  {
    key = 'v',
    mods = 'CMD',
    action = wezterm.action.PasteFrom 'Clipboard',
  },

  -- Quick launch Flutter commands
  {
    key = 'r',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString 'flutter run\r',
  },
  {
    key = 'h',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString 'r',  -- Hot reload shortcut
  },
  {
    key = 'R',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString 'R',  -- Hot restart shortcut
  },
  {
    key = 'q',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString 'q',  -- Quit Flutter app
  },

  -- Quick access to common development commands
  {
    key = 'g',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString 'git status\r',
  },
  {
    key = 'l',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SendString 'ls -la\r',
  },

  -- Clear terminal
  {
    key = 'k',
    mods = 'CMD',
    action = wezterm.action.SendString '\x0c',
  },

  -- ===============================================
  -- Enhanced development bindings
  -- ===============================================
  -- Copy and Paste enhancements
  { key = 'c', mods = 'SHIFT|CTRL', action = wezterm.action { CopyTo = 'Clipboard' } },
  { key = 'v', mods = 'SHIFT|CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'u', mods = 'SHIFT|CTRL', action = wezterm.action.ScrollByPage(-0.5) },
  { key = 'd', mods = 'SHIFT|CTRL', action = wezterm.action.ScrollByPage(0.5) },
  { key = 'g', mods = 'SHIFT|CTRL', action = wezterm.action.ScrollToBottom },

  -- Vim-style navigation
  { key = 'h', mods = 'CTRL', action = wezterm.action.SendKey { key = 'LeftArrow' } },
  { key = 'j', mods = 'CTRL', action = wezterm.action.SendKey { key = 'DownArrow' } },
  { key = 'k', mods = 'CTRL', action = wezterm.action.SendKey { key = 'UpArrow' } },
  { key = 'l', mods = 'CTRL', action = wezterm.action.SendKey { key = 'RightArrow' } },

  -- Font size controls
  { key = '+', mods = 'CTRL|SHIFT', action = 'IncreaseFontSize' },
  { key = '_', mods = 'CTRL|SHIFT', action = 'DecreaseFontSize' },
  { key = 'Backspace', mods = 'CTRL|SHIFT', action = 'ResetFontSize' },

  -- Tab movement
  { key = '{', mods = 'SHIFT|ALT', action = wezterm.action.MoveTabRelative(-1) },
  { key = '}', mods = 'SHIFT|ALT', action = wezterm.action.MoveTabRelative(1) },

  -- Configuration reload
  { key = 'F5', action = 'ReloadConfiguration' },
}

-- ===============================================
-- Flutter Development Optimizations
-- ===============================================

-- Environment variables for Flutter development
config.set_environment_variables = {
  -- Optimize for Flutter development
  FLUTTER_ROOT = '/opt/homebrew/bin/flutter',
  ANDROID_HOME = wezterm.home_dir .. '/Library/Android/sdk',
  JAVA_HOME = '/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home',
  
  -- Terminal optimizations
  TERM = 'xterm-256color',
  COLORTERM = 'truecolor',
}

-- ===============================================
-- Session and Startup Configuration
-- ===============================================

-- Default startup command (launches tmux session with unique session per window)
-- config.default_prog = { '/opt/homebrew/bin/tmux', 'new-session', '-A', '-s', 'main' }

-- Working directory
config.default_cwd = wezterm.home_dir .. '/development'

-- ===============================================
-- Performance Optimizations
-- ===============================================

-- GPU acceleration
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'

-- Animation performance
config.animation_fps = 60
config.max_fps = 60

-- Memory management
config.scrollback_lines = 10000

-- ===============================================
-- Terminal Bell and Notifications
-- ===============================================

-- Audio bell configuration (視覚的フィードバック)
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}

-- Window background settings (作業効率向上のため)
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- Terminal cursor settings (視認性向上)
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 800

-- ===============================================
-- Advanced Features
-- ===============================================

-- Mouse bindings
config.mouse_bindings = {
  -- Right click paste
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  
  -- Ctrl+Click to open URLs
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- Hyperlink rules (useful for Flutter stack traces)
config.hyperlink_rules = {
  -- File paths in Flutter error messages
  {
    regex = [[\b[a-zA-Z]:[\\/][^\s:]+:(\d+):(\d+)\b]],
    format = 'file://$0',
  },
  -- Standard URLs
  {
    regex = [[\bhttps?://[^\s\)]+\b]],
    format = '$0',
  },
  -- Flutter package URLs
  {
    regex = [[\bpackage:[^\s\)]+\b]],
    format = '$0',
  },
}

-- ===============================================
-- Tab Styling for Development Context
-- ===============================================

-- ===============================================
-- Status Bar Integration System
-- ===============================================

-- Claudeステータスを要素に追加する関数
local function add_claude_status_to_elements(elements, tab_sessions, window)
  if not tab_sessions or #tab_sessions == 0 then
    return
  end

  -- Claudeタブのみ表示
  local claude_count = 0
  for i, tab_session in ipairs(tab_sessions) do
    if tab_session.has_claude then
      if claude_count > 0 then
        table.insert(elements, { Text = CLAUDE_CONSTANTS.SPACING_SINGLE })
      end
      
      table.insert(elements, { Foreground = { Color = CLAUDE_CONSTANTS.COLOR_ICON } })
      local emoji = tab_session.running and CLAUDE_CONSTANTS.EMOJI_RUNNING or CLAUDE_CONSTANTS.EMOJI_IDLE
      table.insert(elements, { Text = emoji })
      claude_count = claude_count + 1
    end
  end
  
  table.insert(elements, { Text = CLAUDE_CONSTANTS.SPACING_SINGLE })
end

-- 右ステータスバー更新機能
config.status_update_interval = 500 -- 0.5秒ごとに更新

wezterm.on('update-right-status', function(window, pane)
  local elements = {}

  -- Claude ステータスを取得
  local claude_status = get_claude_status(window)
  
  -- デバッグ: Claude検出状況をログ出力（一時的）
  if claude_status and claude_status.tab_sessions then
    local has_any_claude = false
    for _, session in ipairs(claude_status.tab_sessions) do
      if session.has_claude then
        has_any_claude = true
        break
      end
    end
    if has_any_claude then
      wezterm.log_info("Claude detected in tabs: " .. #claude_status.tab_sessions)
    end
  end
  
  local cwd = pane:get_current_working_dir()
  if not cwd then
    -- Claude ステータスのみ表示
    add_claude_status_to_elements(elements, claude_status.tab_sessions, window)
    window:set_right_status(wezterm.format(elements))
    return
  end

  local cwd_path = cwd.file_path

  -- Git情報を取得
  local git_info = get_git_info(cwd_path)
  
  -- Git 表示
  if git_info and git_info.repo_name then
    table.insert(elements, { Foreground = { Color = CLAUDE_CONSTANTS.GIT_ICON_COLOR } })
    table.insert(elements, { Text = '  ' })
    table.insert(elements, { Foreground = { Color = CLAUDE_CONSTANTS.GIT_REPO_COLOR } })
    table.insert(elements, { Text = git_info.repo_name })

    if git_info.branch then
      table.insert(elements, { Foreground = { Color = CLAUDE_CONSTANTS.GIT_BRANCH_ICON_COLOR } })
      table.insert(elements, { Text = CLAUDE_CONSTANTS.SPACING_MEDIUM })
      table.insert(elements, { Foreground = { Color = CLAUDE_CONSTANTS.GIT_BRANCH_COLOR } })
      table.insert(elements, { Text = git_info.branch })
    end
  end

  -- Claude ステータス表示（最後に表示）
  local has_claude = false
  for _, tab_session in ipairs(claude_status.tab_sessions) do
    if tab_session.has_claude then
      has_claude = true
      break
    end
  end
  
  if has_claude then
    table.insert(elements, { Text = CLAUDE_CONSTANTS.SPACING_SMALL })
    add_claude_status_to_elements(elements, claude_status.tab_sessions)
  end

  window:set_right_status(wezterm.format(elements))
end)

-- タブアクティブ時の即座更新
wezterm.on('tab-active', function(tab, pane, window)
  -- すぐに更新をトリガー
  wezterm.emit('update-right-status', window, pane)
  
  -- 少し遅れてもう一度更新（確実性向上）
  wezterm.time.call_after(0.1, function()
    wezterm.emit('update-right-status', window, pane)
  end)
end)

-- Enhanced tab title formatting with improved visibility and naming
wezterm.on('format-tab-title', function(tab, tabs, panes, conf, hover, max_width)
  -- カラースキーマ（視認性重視）
  local background = '#2d3748'  -- ダークグレー
  local foreground = '#e2e8f0'  -- ライトグレー
  local edge_background = '#1a202c'  -- より暗いグレー
  local tab_index_color = '#68d391'  -- グリーン

  if tab.is_active then
    background = '#3182ce'  -- ブルー
    foreground = '#ffffff'  -- ホワイト
    tab_index_color = '#ffd700'  -- ゴールド
  elseif hover then
    background = '#4a5568'  -- ライトグレー
    foreground = '#ffffff'
  end
  
  local edge_foreground = background

  -- プロセス情報を取得
  local process_name = tab.active_pane.foreground_process_name or ''
  local title = tab.active_pane.title or ''
  local cwd = tab.active_pane.current_working_dir
  local cwd_path = cwd and cwd.file_path or ''
  
  -- ディレクトリ名を取得
  local dir_name = ''
  if cwd_path ~= '' then
    dir_name = cwd_path:match('([^/]+)$') or ''
  end

  -- タブタイトルとアイコンを決定
  local icon = ''
  local display_title = ''
  
  if process_name:match('nvim') or title:match('nvim') then
    icon = ''  -- Neovim icon
    display_title = dir_name ~= '' and ('nvim: ' .. dir_name) or 'nvim'
  elseif process_name:match('flutter') or title:match('flutter') then
    icon = '󰔬'  -- Flutter icon
    display_title = dir_name ~= '' and ('flutter: ' .. dir_name) or 'flutter'
  elseif process_name:match('dart') or title:match('dart') then
    icon = ''  -- Dart icon
    display_title = dir_name ~= '' and ('dart: ' .. dir_name) or 'dart'
  elseif process_name:match('git') or title:match('git') or process_name:match('lazygit') then
    icon = ''  -- Git icon
    display_title = dir_name ~= '' and ('git: ' .. dir_name) or 'git'
  elseif process_name:match('node') or process_name:match('npm') then
    icon = ''  -- Node.js icon
    display_title = dir_name ~= '' and ('node: ' .. dir_name) or 'node'
  elseif process_name:match('python') or process_name:match('py') then
    icon = ''  -- Python icon
    display_title = dir_name ~= '' and ('python: ' .. dir_name) or 'python'
  elseif process_name:match('rust') or process_name:match('cargo') then
    icon = ''  -- Rust icon
    display_title = dir_name ~= '' and ('rust: ' .. dir_name) or 'rust'
  elseif process_name:match('go') then
    icon = ''  -- Go icon
    display_title = dir_name ~= '' and ('go: ' .. dir_name) or 'go'
  elseif process_name:match('docker') then
    icon = ''  -- Docker icon
    display_title = 'docker'
  elseif process_name:match('claude') or title:match('claude') then
    icon = '󰚩'  -- AI/Robot icon
    display_title = 'claude'
  elseif process_name:match('zsh') or process_name:match('bash') then
    icon = ''  -- Terminal icon
    display_title = dir_name ~= '' and dir_name or 'terminal'
  else
    icon = ''  -- Default terminal icon
    display_title = dir_name ~= '' and dir_name or (title ~= '' and title or 'shell')
  end

  -- タブインデックスを含む最終タイトル
  local tab_number = tab.tab_index + 1
  local final_title = string.format('%d: %s %s', tab_number, icon, display_title)
  
  -- 長すぎる場合は切り詰め
  if string.len(final_title) > max_width - 4 then
    final_title = string.sub(final_title, 1, max_width - 7) .. '...'
  end

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = ' ' },
    { Background = { Color = background } },
    { Foreground = { Color = tab_index_color } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = tostring(tab_number) },
    { Foreground = { Color = foreground } },
    { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
    { Text = ': ' .. icon .. ' ' .. display_title .. ' ' },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = '' },
  }
end)

-- ===============================================
-- SSH and Remote Development
-- ===============================================

-- SSH connection helper (リモート開発支援)
config.ssh_domains = {
  {
    name = 'server',
    remote_address = 'your-server.example.com',
    username = 'your-username',
  },
}

-- Unix domain socket for local development
config.unix_domains = {
  {
    name = 'unix',
  },
}

-- ===============================================
-- Text Selection and Copy Behavior
-- ===============================================

-- Copy behavior settings (効率的なコピー操作)
config.selection_word_boundary = ' \t\n{}[]()"\'-.,;:'
config.bypass_mouse_reporting_modifiers = 'SHIFT'

-- ===============================================
-- Workspace Configuration for Projects
-- ===============================================


-- Single pane startup with smart tab naming
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  
  -- Set initial window size for development
  window:gui_window():set_inner_size(1600, 1000)
  
  -- Set initial tab title
  tab:set_title('1:  main')
end)

-- Auto-name new tabs based on content
wezterm.on('new-tab', function(tab, pane, window)
  -- Get the current working directory for context
  local cwd = pane:get_current_working_dir()
  local dir_name = ''
  
  if cwd and cwd.file_path then
    dir_name = cwd.file_path:match('([^/]+)$') or ''
  end
  
  local tab_number = tab.tab_index + 1
  local default_title = dir_name ~= '' and (tab_number .. ':  ' .. dir_name) or (tab_number .. ':  terminal')
  
  tab:set_title(default_title)
end)

-- Update tab title when process changes
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local zoomed = ''
  if tab.active_pane.is_zoomed then
    zoomed = '[Z] '
  end

  local index = ''
  if #tabs > 1 then
    index = string.format('[%d/%d] ', tab.tab_index + 1, #tabs)
  end

  return zoomed .. index .. tab.active_pane.title
end)


return config