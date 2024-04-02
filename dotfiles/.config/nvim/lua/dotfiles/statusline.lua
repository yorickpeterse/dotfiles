local M = {}
local default_name = '[No Name]'
local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local diag = vim.diagnostic
local git = require('dotfiles.git')
local util = require('dotfiles.util')
local diags = require('dotfiles.diagnostics')
local highlight = util.statusline_highlight
local separator = '%='
local active_tab = 'StatusLineTab'
local inactive_tab = 'StatusLine'

-- A cache of all diagnostics.
--
-- Statuslines are redrawn often, and obtaining all diagnostics can be expensive
-- when there are many, as `vim.diagnostic.get()` appears to perform various
-- allocations and deep copies.
local diagnostics_cache = {}

-- A cache of the LSP client states.
local lsp_status_cache = nil

local function diagnostic_count(kind, foreground, background)
  local severity = kind == 'E' and diag.severity.ERROR or diag.severity.WARN
  local amount = 0
  local cached = diagnostics_cache[severity]

  if cached then
    amount = cached
  else
    amount = #diag.get(nil, { severity = severity })
    diagnostics_cache[severity] = amount
  end

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

local function git_status()
  local branch = git.branch()

  if branch == '' then
    return ''
  end

  local msg = git.progress()
  local line = '󰘬 ' .. branch

  if #msg > 0 then
    line = line .. ', ' .. msg
  end

  return highlight(line, 'Comment')
end

local function lsp_status()
  local statuses = lsp_status_cache

  if not statuses then
    statuses = {}

    for _, client in ipairs(lsp.get_clients()) do
      for progress in client.progress do
        local msg = progress.value

        if type(msg) == 'table' and msg.kind then
          local status = ''

          if msg.kind == 'end' then
            status = 'idle'
          else
            status = msg.title

            if msg.percentage then
              status = status .. ' ' .. msg.percentage .. '%%'
            end
          end

          statuses[client.name] = status
        end
      end
    end

    for _, client in ipairs(lsp.get_clients()) do
      if not statuses[client.name] then
        statuses[client.name] = 'idle'
      end
    end

    lsp_status_cache = statuses
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

  return highlight(table.concat(cells, ', '), 'Comment')
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

    line = table.concat({
      line,
      index > 1 and ' ' or '',
      '%#',
      index == fn.tabpagenr() and active_tab or inactive_tab,
      '#',
      index,
      ': ',
      tabname,
      '%*',
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

function M.render()
  local elements = vim.tbl_filter(function(v)
    return #v > 0
  end, {
    line_diagnostic(),
    separator,
    git_status(),
    lsp_status(),
    tabline(),
    diagnostic_count('W', 'WarningMsg', 'WhiteOnYellow'),
    diagnostic_count('E', 'ErrorMsg', 'WhiteOnRed'),
  })

  return table.concat(elements, ' ')
end

function M.refresh_diagnostics()
  diagnostics_cache = {}
end

function M.refresh_lsp_status()
  lsp_status_cache = nil
end

return M
