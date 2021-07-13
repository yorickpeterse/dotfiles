local M = {}
local icons = require('nvim-web-devicons')
local fn = vim.fn

icons.setup {
  override = {
    ["Terminal"] = {
      icon = "",
      color = "#31B53E",
      name = "Terminal"
    },
  },
}

-- Returns an icon for the given path name, padded with a trailing space.
function M.icon(path)
  -- We use require() here as this module is loaded before plugins are
  -- available.
  local base_name = fn.fnamemodify(path, ':t')
  local ext_name = fn.fnamemodify(path, ':e')

  -- for ad-hoc terminals I want the same icon as those explicitly called
  -- "Terminal"
  if vim.startswith(path, 'term://') then
    base_name = 'terminal'
  end

  if vim.endswith(path, '.git/index') then
    base_name = 'git'
  end

  local icon = icons.get_icon(base_name, ext_name) or
    icons.get_icon(base_name:lower(), ext_name)

  if icon then
    return icon .. ' '
  else
    return ''
  end
end

return M
