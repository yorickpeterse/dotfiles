local fn = vim.fn
local M = {}
local lsp = vim.lsp
local api = vim.api
local icons = require('dotfiles.icons')
local util = require('dotfiles.util')
local highlight = util.statusline_highlight
local forced_space = util.forced_space

local active_tab = 'TabLineSel'
local inactive_tab = 'TabLine'
local default_name = '[No Name]'
local separator = '%='
local lsp_hl = 'TabLine'

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
      statuses[client.name] = 'active'
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

  return forced_space
    .. highlight(table.concat(cells, ', '), lsp_hl)
    .. forced_space
end

function M.render()
  local line = ''

  for index, tab_handle in ipairs(api.nvim_list_tabpages()) do
    local win = api.nvim_tabpage_get_win(tab_handle)
    local bufnr = api.nvim_win_get_buf(win)
    local bufname = fn.bufname(bufnr)

    if bufname == '' then
      bufname = default_name
    else
      bufname = fn.fnamemodify(bufname, ':t'):gsub('%%', '%%%%')
    end

    local modified = api.nvim_buf_get_option(bufnr, 'mod')

    line = line
      .. table.concat({
        '%',
        index,
        'T',
        '%#',
        index == fn.tabpagenr() and active_tab or inactive_tab,
        '#',
        ' ',
        index,
        ': ',
        icons.icon(bufname),
        bufname,
        ' ',
        modified and '[+] ' or '',
      })
  end

  return line .. '%#TabLineFill#' .. separator .. lsp_status()
end

return M
