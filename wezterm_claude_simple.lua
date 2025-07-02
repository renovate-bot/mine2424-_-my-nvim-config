-- Simplified Claude monitoring for WezTerm
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Basic config
config.font_size = 11
config.window_background_opacity = 0.8
config.status_update_interval = 100 -- 0.1秒ごとに更新

-- Simple Claude detection function
local function get_claude_status()
  local success, stdout = wezterm.run_child_process {
    '/bin/ps',
    'aux'
  }
  
  if not success or not stdout then
    return { has_claude = false, is_active = false }
  end
  
  for line in stdout:gmatch('[^\n]+') do
    if line:lower():match('claude') and not line:match('grep') then
      -- Extract CPU usage (3rd field in ps aux)
      local cpu = line:match('%S+%s+%S+%s+(%S+)')
      local cpu_usage = tonumber(cpu) or 0
      
      return {
        has_claude = true,
        is_active = cpu_usage > 0.5
      }
    end
  end
  
  return { has_claude = false, is_active = false }
end

-- Update status bar
wezterm.on('update-right-status', function(window, pane)
  local status = get_claude_status()
  local text = ''
  
  if status.has_claude then
    if status.is_active then
      text = '⚡ Claude Active'
    else
      text = '🤖 Claude Idle'
    end
  else
    text = '❌ No Claude'
  end
  
  window:set_right_status(wezterm.format({
    { Foreground = { Color = '#FF6B6B' } },
    { Text = text },
  }))
end)

return config