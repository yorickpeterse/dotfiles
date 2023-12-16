local M = {}
local default_name = '[No Name]'
local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local diag = vim.diagnostic
local util = require('dotfiles.util')
local diags = require('dotfiles.diagnostics')
local highlight = util.statusline_highlight
local separator = '%='
local active_tab = 'StatusLineTab'
local inactive_tab = 'StatusLine'
local mode_map = {
  ['n'] = 'NORMAL',
  ['no'] = 'O-PENDING',
  ['nov'] = 'O-PENDING',
  ['noV'] = 'O-PENDING',
  ['no\22'] = 'O-PENDING',
  ['niI'] = 'NORMAL',
  ['niR'] = 'NORMAL',
  ['niV'] = 'NORMAL',
  ['nt'] = 'NORMAL',
  ['ntT'] = 'NORMAL',
  ['v'] = 'VISUAL',
  ['vs'] = 'VISUAL',
  ['V'] = 'V-LINE',
  ['Vs'] = 'V-LINE',
  ['\22'] = 'V-BLOCK',
  ['\22s'] = 'V-BLOCK',
  ['s'] = 'SELECT',
  ['S'] = 'S-LINE',
  ['\19'] = 'S-BLOCK',
  ['i'] = 'INSERT',
  ['ic'] = 'INSERT',
  ['ix'] = 'INSERT',
  ['R'] = 'REPLACE',
  ['Rc'] = 'REPLACE',
  ['Rx'] = 'REPLACE',
  ['Rv'] = 'V-REPLACE',
  ['Rvc'] = 'V-REPLACE',
  ['Rvx'] = 'V-REPLACE',
  ['c'] = 'COMMAND',
  ['cv'] = 'EX',
  ['ce'] = 'EX',
  ['r'] = 'REPLACE',
  ['rm'] = 'MORE',
  ['r?'] = 'CONFIRM',
  ['!'] = 'SHELL',
  ['t'] = 'TERMINAL',
}

local ignore_modes = { NORMAL = true, INSERT = true, COMMAND = true }

local function diagnostic_count(kind, foreground, background)
  local severity = kind == 'E' and diag.severity.ERROR or diag.severity.WARN
  local amount = #diag.get(nil, { severity = severity })

  if amount > 0 then
    return table.concat({
      highlight('', foreground),
      highlight(table.concat({ kind, ': ', amount }, ''), background),
      highlight('', foreground),
    }, '')
  else
    return ''
  end
end

local function lsp_status()
  local statuses = {}

  for _, client in ipairs(lsp.get_clients()) do
    for progress in client.progress do
      local msg = progress.value

      if type(msg) == 'table' and msg.kind then
        local status = msg.title

        if msg.percentage then
          status = status .. ' ' .. msg.percentage .. '%%'
        end

        statuses[client.name] = status
      end
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

  return table.concat(cells, ', ')
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
        index,
        ': ',
        tabname,
        '%*',
        ' ',
      }, '')
  end

  return line
end

local function line_diagnostic()
  if diags.diagnostic then
    return diags.diagnostic
  else
    return ''
  end
end

local function mode()
  local mode = api.nvim_get_mode().mode
  local kind = mode_map[mode] or mode

  if ignore_modes[kind] then
    return ''
  else
    return '%#PmenuSel# ' .. kind .. ' %*'
  end
end

function M.render()
  local elements = vim.tbl_filter(function(v)
    return #v > 0
  end, {
    line_diagnostic(),
    separator,
    mode(),
    lsp_status(),
    tabline(),
    diagnostic_count('W', 'WarningMsg', 'WhiteOnYellow'),
    diagnostic_count('E', 'ErrorMsg', 'WhiteOnRed'),
  })

  return table.concat(elements, ' ')
end

return M
