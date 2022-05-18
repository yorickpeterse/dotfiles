local fn = vim.fn
local M = {}
local api = vim.api

local active_tab = 'TabLineSel'
local inactive_tab = 'TabLine'
local default_name = '[No Name]'
local separator = '%='

function M.render()
  local line = ''

  for index, tab_handle in ipairs(api.nvim_list_tabpages()) do
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
        '%',
        index,
        'T',
        '%#',
        index == fn.tabpagenr() and active_tab or inactive_tab,
        '#',
        ' ',
        index,
        ': ',
        tabname,
        ' ',
      })
  end

  return line .. '%#TabLineFill#'
end

return M
