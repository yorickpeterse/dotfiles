local M = {}

-- This is the "EN SPACE" character. Regular and unbreakable spaces sometimes
-- get swallowed in statuslines. This kind of space doesn't.
-- local forced_space = utf8.char(8194)
local forced_space = string.char(226, 128, 130)

local preview = '%w'
local modified = '%m'
local readonly = '%r'
local separator = '%='

local function diagnostic_count(kind)
  local amount = vim.lsp.diagnostic.get_count(0, kind)

  if amount > 0 then
    return forced_space .. kind:sub(1, 1) .. ': ' .. amount .. forced_space
  else
    return ''
  end
end

local function highlight(text, group)
  return '%#' .. group .. '#' .. text .. '%*'
end

-- Renders the status line.
function M.render()
  local active = vim.g.statusline_winid == vim.api.nvim_get_current_win()

  return table.concat({
    active and highlight(' %f ', 'BlackOnLightYellow') or ' %f ',
    preview,
    modified,
    readonly,
    separator,
    highlight(diagnostic_count('Warning'), 'WhiteOnYellow'),
    highlight(diagnostic_count('Error'), 'WhiteOnRed'),
  })
end

return M
