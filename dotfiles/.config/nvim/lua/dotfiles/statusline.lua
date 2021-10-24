local M = {}
local api = vim.api
local fn = vim.fn
local diag = vim.diagnostic
local lsp = vim.lsp
local icons = require('dotfiles.icons')
local util = require('dotfiles.util')
local highlight = util.statusline_highlight
local forced_space = util.forced_space

local preview = '%w'
local modified = '%m'
local readonly = '%r'
local separator = '%='
local active_hl = 'BlackOnLightYellow'
local git_hl = 'WhiteOnBlue'

local function diagnostic_count(buffer, kind)
  local severity = kind == 'E' and diag.severity.ERROR or diag.severity.WARN
  local amount = #diag.get(buffer, { severity = severity })

  if amount > 0 then
    return forced_space .. kind .. ': ' .. amount .. forced_space
  else
    return ''
  end
end

function M.render()
  local window = vim.g.statusline_winid
  local active = window == api.nvim_get_current_win()
  local buffer = api.nvim_win_get_buf(window)
  local bufname = fn.bufname(buffer)

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

  local icon = icons.icon(bufname)

  -- Escape any literal percent signs so they aren't evaluated.
  bufname = bufname:gsub('%%', '%%%%')
  bufname = fn.fnamemodify(bufname, ':.')

  local name = ' ' .. icon .. bufname .. ' '
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
