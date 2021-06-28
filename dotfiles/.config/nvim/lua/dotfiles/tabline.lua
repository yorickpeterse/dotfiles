local fn = vim.fn
local M = {}

local active_tab = 'TabLineSel'
local inactive_tab = 'TabLine'
local default_name = '[No Name]'

-- Renders the tabline.
function M.render()
  local line = ''

  for tab = 1, fn.tabpagenr('$') do
    local winnr = fn.tabpagewinnr(tab)
    local buflist = fn.tabpagebuflist(tab)
    local bufnr = buflist[winnr]
    local bufname = fn.bufname(bufnr)

    if bufname == '' then
      bufname = default_name
    else
      bufname = fn.fnamemodify(bufname, ':t')
    end

    local modified = fn.getbufvar(bufnr, '&mod')

    line = line .. table.concat({
      '%',
      tab,
      'T',
      '%#',
      tab == fn.tabpagenr() and active_tab or inactive_tab,
      '#',
      ' ',
      tab,
      ': ',
      bufname,
      ' ',
      modified == 1 and '[+] ' or ''
    })
  end

  return line .. '%#TabLineFill#'
end

return M
