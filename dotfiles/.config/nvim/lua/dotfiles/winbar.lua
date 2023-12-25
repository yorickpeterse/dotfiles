local M = {}
local api = vim.api
local fn = vim.fn

local NO_NAME = '[No name]'

function M.render()
  local win = vim.g.statusline_winid
  local buf = api.nvim_win_get_buf(win)
  local typ = vim.bo[buf].buftype
  local name = nil
  local flags = nil

  if typ == 'quickfix' then
    local has_title, qf_title =
      pcall(api.nvim_win_get_var, win, 'quickfix_title')

    name = (has_title and qf_title) and qf_title or NO_NAME
    flags = ''
  else
    local bufname = api.nvim_buf_get_name(buf)

    if bufname == '' then
      bufname = NO_NAME
    end

    -- Escape any literal percent signs so they aren't evaluated.
    if bufname:match('%%') then
      bufname = bufname:gsub('%%', '%%%%')
    end

    if typ == 'terminal' and vim.startswith(bufname, 'term://') then
      local parts = vim.split(bufname, ':', { trimempty = true })

      if #parts == 3 then
        bufname = 'term:' .. parts[3]
      end
    else
      bufname = fn.fnamemodify(bufname, ':.')
    end

    name = bufname
    flags = '%( %m%r%)'
  end

  return table.concat({ ' ', name, flags, ' ', '%#WinBarFill#' }, '')
end

return M
