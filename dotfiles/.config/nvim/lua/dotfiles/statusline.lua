local M = {}
local default_name = '[No Name]'
local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local diag = vim.diagnostic
local util = require('dotfiles.util')
local diags = require('dotfiles.diagnostics')
local highlight = util.statusline_highlight
local forced_space = util.forced_space

local separator = '%='
local active_tab = 'StatusLineTab'
local inactive_tab = 'StatusLine'

local function diagnostic_count(kind)
  local severity = kind == 'E' and diag.severity.ERROR or diag.severity.WARN
  local amount = #diag.get(nil, { severity = severity })

  if amount > 0 then
    return forced_space .. kind .. ': ' .. amount .. forced_space
  else
    return ''
  end
end

local function lsp_status()
  local statuses = {}

  for _, msg in ipairs(lsp.util.get_progress_messages()) do
    if not msg.done and not statuses[msg.name] then
      local status = msg.title

      if msg.percentage then
        status = status .. ' ' .. msg.percentage .. '%%'
      end

      statuses[msg.name] = status
    end
  end

  for _, client in ipairs(lsp.get_active_clients()) do
    if not statuses[client.name] then
      statuses[client.name] = 'idle'
    end
  end

  if vim.tbl_isempty(statuses) then
    return ''
  end

  local cells = {}
  local names = {}

  -- This ensures clients are always displayed in a consistent order.
  for name, _ in pairs(statuses) do
    table.insert(names, name)
  end

  table.sort(names, function(a, b)
    return a < b
  end)

  for _, name in ipairs(names) do
    local status = statuses[name]
    local text = name .. ': ' .. status

    table.insert(cells, text)
  end

  return forced_space .. table.concat(cells, ', ') .. forced_space
end

local function tabline()
  local line = ''
  local pages = api.nvim_list_tabpages()

  if #pages == 1 then
    return ''
  end

  for index, tab_handle in ipairs(pages) do
    local win = api.nvim_tabpage_get_win(tab_handle)
    local bufnr = api.nvim_win_get_buf(win)
    local tabname = ''
    local bufname = fn.bufname(bufnr)

    if index == 1 then
      tabname = 'Code'
    else
      if bufname == '' then
        tabname = default_name
      else
        tabname = fn.fnamemodify(bufname, ':t'):gsub('%%', '%%%%')
      end
    end

    line = line
      .. table.concat({
        '%#',
        index == fn.tabpagenr() and active_tab or inactive_tab,
        '#',
        ' ',
        index,
        ': ',
        tabname,
        ' ',
        '%*',
      })
  end

  return line
end

local function line_diagnostic()
  if diags.diagnostic then
    return diags.diagnostic .. forced_space
  else
    return ''
  end
end

function M.render()
  return table.concat({
    line_diagnostic(),
    separator,
    lsp_status(),
    tabline(),
    highlight(diagnostic_count('W'), 'WhiteOnYellow'),
    highlight(diagnostic_count('E'), 'WhiteOnRed'),
  })
end

return M
