require('base')
require('highlights')
require('maps')
require('plugins')

-- Activate system clipboard
local has = function(x)
  return vim.fn.has(x) == 1
end

-- Judge OS
local is_mac = has "macunix"
local is_win = has "win32"

if is_mac then
  require('macos')
end
if is_win then
  require('windows')
end
