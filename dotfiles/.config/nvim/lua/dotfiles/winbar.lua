local M = {}
local api = vim.api
local fn = vim.fn

local separator = '%='
local active_hl = 'BlackOnLightYellow'

function M.render()
  local window = vim.g.statusline_winid
  local buffer = api.nvim_win_get_buf(window)
  local bufname = fn.bufname(buffer)
  local optional_space = ''
  local modified = ''
  local readonly = ''
  local active_hl = ''

  if vim.bo[buffer].readonly then
    optional_space = ' '
    readonly = '[RO]'
  end

  if vim.bo[buffer].modified then
    optional_space = ' '
    modified = '[+]'
  end

  if bufname == '' then
    option_panel = ' '
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

  if vim.startswith(bufname, 'term://') then
    local parts = vim.split(bufname, '//', true)

    if #parts == 3 then
      bufname = 'term://' .. parts[3]
    end
  end

  -- Escape any literal percent signs so they aren't evaluated.
  bufname = bufname:gsub('%%', '%%%%')
  bufname = fn.fnamemodify(bufname, ':.')

  local name = ''
  local has_qf_title, qf_title = pcall(
    api.nvim_win_get_var,
    window,
    'quickfix_title'
  )

  if has_qf_title then
    name = ' ' .. qf_title
  else
    name = ' ' .. bufname
  end

  return table.concat({
    name,
    ' ',
    modified,
    readonly,
    optional_space,
    '%#WinBarFill#',
  })
end

return M
