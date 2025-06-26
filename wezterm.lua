local wezterm = require 'wezterm'
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- ===============================================
-- Basic Configuration
-- ===============================================

-- Font Configuration (optimal for coding)
config.font = wezterm.font_with_fallback {
  {
    family = 'JetBrains Mono',
    weight = 'Medium',
    harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },
  },
  'SF Mono',
  'Menlo',
  'Monaco',
}
config.font_size = 14.0
config.line_height = 1.2

-- Color scheme (Solarized Dark for tmux/nvim consistency)
config.color_scheme = 'Solarized Dark'

-- Window appearance
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.95
config.text_background_opacity = 1.0
config.macos_window_background_blur = 30

-- Tab bar configuration
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_tab_index_in_tab_bar = false

-- Scrollback
config.scrollback_lines = 10000

-- ===============================================
-- tmux Integration & Key Bindings
-- ===============================================

-- Disable default WezTerm key bindings that conflict with tmux
config.disable_default_key_bindings = false

-- Custom key bindings optimized for tmux + nvim workflow
config.keys = {
  -- Pane navigation (works well with tmux)
  {
    key = 'LeftArrow',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },

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

  -- Split panes (complementing tmux)
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
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
    action = wezterm.action.SendString 'flutter run --hot-reload\r',
  },
}

-- ===============================================
-- Flutter Development Optimizations
-- ===============================================

-- Environment variables for Flutter development
config.set_environment_variables = {
  -- Optimize for Flutter development
  FLUTTER_ROOT = '/opt/homebrew/bin/flutter',
  ANDROID_HOME = os.getenv('HOME') .. '/Library/Android/sdk',
  JAVA_HOME = '/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home',
  
  -- Terminal optimizations
  TERM = 'xterm-256color',
  COLORTERM = 'truecolor',
}

-- ===============================================
-- Session and Startup Configuration
-- ===============================================

-- Default startup command (launches tmux session)
config.default_prog = { '/opt/homebrew/bin/tmux', 'new-session', '-A', '-s', 'main' }

-- Working directory
config.default_cwd = os.getenv('HOME') .. '/development'

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

-- Custom tab title formatting
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab.tab_title
  if title and #title > 0 then
    return title
  end
  
  -- Show current directory for development context
  local pane = tab.active_pane
  local process = string.gsub(pane.foreground_process_name, '(.*[/\\])(.*)', '%2')
  
  if process == 'flutter' then
    return 'Flutter 🎯'
  elseif process == 'nvim' then
    return 'NeoVim 📝'
  elseif process == 'tmux' then
    return 'tmux 🖥️'
  else
    return process
  end
end)

-- ===============================================
-- Workspace Configuration for Projects
-- ===============================================

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  
  -- Set initial window size for development
  window:gui_window():set_inner_size(1400, 900)
  
  -- Optional: Auto-split for typical development layout
  -- Uncomment if you want automatic tmux-like layout
  -- local right_pane = pane:split { direction = 'Right', size = 0.3 }
  -- right_pane:send_text 'flutter logs\n'
end)

return config