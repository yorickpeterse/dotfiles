local M = {}

-- This is the "EN SPACE" character. Regular and unbreakable spaces sometimes
-- get swallowed in statuslines. This kind of space doesn't.
-- local forced_space = utf8.char(8194)
local forced_space = string.char(226, 128, 130)

local preview = '%w'
local modified = '%m'
local readonly = '%r'
local separator = '%='
local active_hl = 'BlackOnLightYellow'

local function diagnostic_count(buffer, kind)
  local amount = vim.lsp.diagnostic.get_count(buffer, kind)

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
  local window = vim.g.statusline_winid
  local active = window == vim.api.nvim_get_current_win()
  local buffer = vim.api.nvim_win_get_buf(window)

  return table.concat({
    active and highlight(' %f ', active_hl) or ' %f ',
    preview,
    modified,
    readonly,
    separator,
    highlight(diagnostic_count(buffer, 'Warning'), 'WhiteOnYellow'),
    highlight(diagnostic_count(buffer, 'Error'), 'WhiteOnRed'),
  })
end

-- Renders the statusline for a quickfix window
function M.render_quickfix()
  local window = vim.g.statusline_winid
  local active = window == vim.api.nvim_get_current_win()
  local has_title, title =
    pcall(vim.api.nvim_win_get_var, window, 'quickfix_title')

  return table.concat({
    active and highlight(' %t ', active_hl) or ' %t ',
    has_title and ' ' .. title or ''
  })
end

return M
