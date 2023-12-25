local M = {}
local api = vim.api
local fn = vim.fn

local separator = '%='

function M.render()
  local window = vim.g.statusline_winid
  local buffer = api.nvim_win_get_buf(window)
  local bufname = fn.bufname(buffer)
  local modified = ''
  local readonly = ''

  if vim.bo[buffer].readonly then
    readonly = ' [RO]'
  end

  if vim.bo[buffer].modified then
    modified = ' [+]'
  end

  if bufname == '' then
    bufname = '[No Name]'
  end

  if vim.startswith(bufname, 'term://') then
    local parts = vim.split(bufname, ':', { trimempty = true })

    if #parts == 3 then
      bufname = 'term:' .. parts[3]
    end
  end

  -- Escape any literal percent signs so they aren't evaluated.
  bufname = bufname:gsub('%%', '%%%%')
  bufname = fn.fnamemodify(bufname, ':.')

  local name = ''
  local has_qf_title, qf_title =
    pcall(api.nvim_win_get_var, window, 'quickfix_title')

  if has_qf_title then
    name = qf_title
  else
    name = bufname
  end

  return table.concat({
    ' ',
    name,
    modified,
    readonly,
    ' ',
    '%#WinBarFill#',
  })
end

return M
