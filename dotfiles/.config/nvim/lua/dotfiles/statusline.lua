local M = {}
local api = vim.api
local diag = vim.diagnostic
local icons = require('dotfiles.icons')
local util = require('dotfiles.util')

-- This is the "EN SPACE" character. Regular and unbreakable spaces sometimes
-- get swallowed in statuslines. This kind of space doesn't.
-- local forced_space = utf8.char(8194)
local forced_space = string.char(226, 128, 130)

local preview = '%w'
local modified = '%m'
local readonly = '%r'
local separator = '%='
local active_hl = 'BlackOnLightYellow'
local git_hl = 'WhiteOnBlue'
local diag_counts = util.buffer_cache(function() return {} end)

local function diagnostic_count(buffer, kind)
  local severity = kind == 'E' and diag.severity.ERROR or diag.severity.WARN
  local amount = #diag.get(buffer, { severity = severity })

  -- When in insert mode, a language server may produce new diagnostics as we
  -- type. Constantly updating the statusline in that case is distracting.
  --
  -- Here we ensure we keep displaying the previous value, only refreshing the
  -- diagnostic count when leaving insert mode.
  if util.in_insert_mode() then
    amount = diag_counts[buffer][severity] or 0
  else
    diag_counts[buffer][severity] = amount
  end

  if amount > 0 then
    return forced_space .. kind .. ': ' .. amount .. forced_space
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
  local active = window == api.nvim_get_current_win()
  local buffer = api.nvim_win_get_buf(window)
  local bufname = vim.fn.bufname(buffer)

  if bufname == '' then
    bufname = '[No Name]'
  end

  if vim.startswith(bufname, 'fugitive://') then
    -- Fugitive file paths can get quite long as they use absolute paths. Since
    -- I don't care about the part before the .git/ directory, we'll just strip
    -- that out.
    local parts = vim.split(bufname, '/.git/', true)

    if #parts == 2 then
      bufname = 'fugitive://' .. parts[2]
    end
  end

  local name = ' ' .. icons.icon(bufname) .. bufname .. ' '
  local has_qf_title, qf_title =
    pcall(api.nvim_win_get_var, window, 'quickfix_title')

  return table.concat({
    active and highlight(name, active_hl) or name,
    has_qf_title and ' ' .. qf_title or '',
    ' ',
    preview,
    modified,
    readonly,
    separator,
    highlight(diagnostic_count(buffer, 'W'), 'WhiteOnYellow'),
    highlight(diagnostic_count(buffer, 'E'), 'WhiteOnRed'),
  })
end

return M
