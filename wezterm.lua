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
-- Basic Constants
-- ===============================================
-- Note: Complex monitoring system removed in favor of Starship
-- Starship provides better Git integration and performance monitoring

-- ===============================================
-- Performance Optimizations (OS-specific)
-- ===============================================
config.animation_fps = 60
config.max_fps = 60
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

-- Zenn article inspired color scheme with transparency
config.colors = {
  tab_bar = {
    background = 'rgba(26, 32, 44, 0.95)',  -- Semi-transparent background
    active_tab = {
      bg_color = '#ae8b2d',  -- Golden yellow (Zenn style)
      fg_color = '#ffffff',  -- White text
      intensity = 'Bold',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    inactive_tab = {
      bg_color = 'rgba(92, 109, 116, 0.8)',  -- Muted gray with transparency
      fg_color = '#a0a8b0',  -- Light gray text
      intensity = 'Normal',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    inactive_tab_hover = {
      bg_color = 'rgba(122, 144, 153, 0.9)',  -- Hover effect with transparency
      fg_color = '#ffffff',
      intensity = 'Normal',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    new_tab = {
      bg_color = 'rgba(26, 32, 44, 0.95)',
      fg_color = '#68d391',
      intensity = 'Bold',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    new_tab_hover = {
      bg_color = 'rgba(45, 55, 72, 0.9)',
      fg_color = '#68d391',
      intensity = 'Bold',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
  },
}

-- Window appearance with enhanced transparency
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.85
config.text_background_opacity = 1.0
config.macos_window_background_blur = 20

-- OS-specific transparency adjustments
if os == 'windows' or os == 'linux' then
  config.window_background_opacity = 0.88  -- Slightly less transparent for better readability
end

-- Enhanced Tab bar configuration (Zenn style)
config.enable_tab_bar = true
config.use_fancy_tab_bar = false  -- Use simple tab bar for cleaner look
config.tab_bar_at_bottom = false
config.show_tab_index_in_tab_bar = false  -- Remove tab indices for cleaner look
config.show_new_tab_button_in_tab_bar = false  -- Remove new tab button
-- Remove close buttons - handled by use_fancy_tab_bar = false
config.tab_max_width = 32
config.hide_tab_bar_if_only_one_tab = true  -- Hide when only one tab

-- Scrollback
config.scrollback_lines = 10000

-- ===============================================
-- Process Monitoring (Simplified)
-- ===============================================
-- Note: Complex Claude monitoring system removed
-- Starship provides better status information

-- ===============================================
-- Git Information (Simplified)
-- ===============================================
-- Note: Git information system removed in favor of Starship
-- Starship provides comprehensive Git status in the prompt

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
  
  -- Starship prompt optimization
  STARSHIP_CONFIG = wezterm.home_dir .. '/.config/starship.toml',
  FORCE_COLOR = '1',
  CLICOLOR = '1',
}

-- ===============================================
-- Session and Startup Configuration
-- ===============================================

-- Default startup command (launches tmux session with unique session per window)
-- config.default_prog = { '/opt/homebrew/bin/tmux', 'new-session', '-A', '-s', 'main' }

-- Working directory
config.default_cwd = wezterm.home_dir .. '/development'

-- ===============================================
-- Memory Management
-- ===============================================
-- Note: Other performance settings are configured at the top of the file

-- ===============================================
-- Terminal Bell and Notifications
-- ===============================================

-- Audio bell configuration (integrated - removed duplicate)
-- Note: audible_bell is configured in the bell event handler above

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
-- Note: SSH domains removed as they were unused
-- Add back if remote development is needed

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