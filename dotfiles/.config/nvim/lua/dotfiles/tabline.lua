local fn = vim.fn
local M = {}
local lsp = vim.lsp
local api = vim.api
local icons = require('dotfiles.icons')

local active_tab = 'TabLineSel'
local inactive_tab = 'TabLine'
local default_name = '[No Name]'
local separator = '%='

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

  return line .. '%#TabLineFill#'
end

return M
