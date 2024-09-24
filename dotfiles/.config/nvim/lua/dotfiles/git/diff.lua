local api = vim.api
local fn = vim.fn
local util = require('dotfiles.util')

local M = {}
local NAMESPACE = api.nvim_create_namespace('dotfiles_git_diff')
local AUGROUP = api.nvim_create_augroup('dotfiles_git_diff', { clear = true })

-- The highlight groups to use for the different file modes. We use the same
-- highlight groups as diffview.nvim.
local STATUS_HL = {
  ['A'] = 'DiffviewStatusAdded',
  ['?'] = 'DiffviewStatusUntracked',
  ['M'] = 'DiffviewStatusModified',
  ['R'] = 'DiffviewStatusRenamed',
  ['C'] = 'DiffviewStatusCopied',
  ['T'] = 'DiffviewStatusTypeChanged',
  ['U'] = 'DiffviewStatusUnmerged',
  ['X'] = 'DiffviewStatusUnknown',
  ['D'] = 'DiffviewStatusDeleted',
  ['B'] = 'DiffviewStatusBroken',
  ['!'] = 'DiffviewStatusIgnored',
}

-- The highlight groups to use for the sidebar.
local SIDEBAR_HL = {
  -- The highlight to apply to directory names.
  directory = 'Directory',

  -- The highlight to apply to the staged marker.
  staged = 'Title',

  -- The highlight to apply to the unstaged marker.
  unstaged = 'Comment',

  -- The highlight group to use for the cursor line.
  cursor_line = 'DiffviewCursorLine',
}

-- The window-local highlight options to use for the diff windows.
local DIFF_HL = {
  before = 'DiffAdd:DiffviewDiffAddAsDelete,DiffDelete:DiffviewDiffDeleteDim',
  after = 'DiffDelete:DiffviewDiffDeleteDim',
}

-- The index/line of the initial file to show.
local INIT_INDEX = 2

local CONFIG = {
  refresh = 'r',
  select_file = '<CR>',
  stage_file = '-',
  undo_file = 'x',
  next_file = ']f',
  prev_file = '[f',
}

local STATE = {}

local function join(a, b)
  return a .. '/' .. b
end

local function git_root()
  local res = vim.system({ 'git', 'rev-parse', '--show-toplevel' }):wait()

  return vim.trim(res.stdout)
end

local function git_status()
  local res = vim.system({ 'git', 'status', '--porcelain' }):wait()

  assert(res.code == 0)

  local paths = {}

  for _, line in ipairs(vim.split(res.stdout, '\n', { trimempty = true })) do
    local staged = line:sub(1, 1)
    local unstaged = line:sub(2, 2)
    local path = line:sub(4, #line)

    if
      (staged == ' ' or staged == '?') or (staged ~= ' ' and unstaged ~= ' ')
    then
      -- If a file is both staged and unstaged, we treat it as unstaged.
      paths[path] = { staged = false, status = unstaged, name = path }
    else
      paths[path] = { staged = true, status = staged, name = path }
    end
  end

  local rows = vim.tbl_values(paths)

  table.sort(rows, function(a, b)
    return a.name < b.name
  end)

  return rows
end

local function git_stage(root, path)
  assert(vim.system({ 'git', 'add', join(root, path) }):wait().code == 0)
end

local function git_unstage(root, path)
  assert(
    vim.system({ 'git', 'restore', '--staged', join(root, path) }):wait().code
      == 0
  )
end

local function git_undo(root, path)
  assert(vim.system({ 'git', 'restore', join(root, path) }):wait().code == 0)
end

local function git_diff(start, stop)
  local res = vim
    .system({ 'git', 'diff', '--name-status', start .. '...' .. stop })
    :wait()

  assert(res.code == 0)

  local paths = {}

  for _, line in ipairs(vim.split(res.stdout, '\n', { trimempty = true })) do
    local status, file = unpack(vim.split(line, '\t'))

    table.insert(paths, { status = status, name = file })
  end

  return paths
end

local function git_parent(start)
  local res = vim.system({ 'git', 'rev-parse', start .. '^' }):wait()

  assert(res.code == 0)

  return vim.trim(res.stdout)
end

local function git_show(rev, file)
  local res = vim.system({ 'git', 'show', rev .. ':' .. file }):wait()

  if res.code == 0 then
    return vim.split(res.stdout, '\n', { trimempty = true })
  else
    return {}
  end
end

local function close_diff_windows()
  for _, win in ipairs(STATE.diff_windows) do
    if api.nvim_win_is_valid(win) then
      api.nvim_win_close(win, true)
    end
  end
end

local function new_state(start, stop, parent, paths)
  return {
    -- The root directory of the Git repository.
    root = git_root(),

    -- The window and buffer of the status sidebar.
    status = { win = nil, buf = nil },

    -- The windows containing the before and after diffs.
    diff_windows = {},

    -- The end of the revision range to show.
    stop = stop,

    -- The parent of the start revision.
    parent = parent,

    -- The paths to diff.
    paths = paths,

    -- The index/line number of the currently active file.
    file_index = INIT_INDEX,

    -- The line numbers of the status buffer that contain file paths.
    file_lines = {},

    -- Whether we're staging changes or just viewing them.
    staging = start == nil,
  }
end

local function render_diffs()
  local path = STATE.file_lines[STATE.file_index]

  if not path then
    return
  end

  local prev_win = api.nvim_get_current_win()

  close_diff_windows()

  -- Even though we close the windows, Neovim seems to keep their diff state
  -- around unless we explicitly disable diffing for all windows in the current
  -- tab.
  vim.cmd('diffoff!')

  -- Show the window containing the old version.
  local before = git_show(STATE.parent, path.name)
  local before_name = 'diff://' .. STATE.parent .. '/' .. path.name
  local before_buf = api.nvim_create_buf(false, true)
  local before_win = api.nvim_open_win(
    before_buf,
    true,
    { split = 'right', win = STATE.status.win }
  )

  api.nvim_buf_set_lines(before_buf, 0, -1, true, before)
  api.nvim_buf_set_name(before_buf, before_name)
  vim.wo[before_win].winhl = DIFF_HL.before
  vim.wo[before_win].winbar = 'Before: ' .. path.name
  vim.bo[before_buf].buftype = 'nofile'
  vim.bo[before_buf].bufhidden = 'wipe'
  vim.bo[before_buf].modifiable = false
  vim.bo[before_buf].readonly = true
  vim.cmd.filetype('detect')
  vim.cmd.diffthis()

  -- Show the window containing the new version.
  local after
  local after_name
  local after_buf
  local after_win

  if STATE.staging then
    vim.cmd('vne ' .. STATE.root .. '/' .. path.name)
    after_win = api.nvim_get_current_win()
    after_buf = api.nvim_win_get_buf(after_win)
  else
    after = git_show(STATE.stop, path.name)
    after_name = 'diff://' .. STATE.stop .. '/' .. path.name
    after_buf = api.nvim_create_buf(false, true)
    after_win =
      api.nvim_open_win(after_buf, true, { split = 'right', win = before_win })
    api.nvim_buf_set_lines(after_buf, 0, -1, true, after)
    api.nvim_buf_set_name(after_buf, after_name)
    vim.bo[after_buf].buftype = 'nofile'
    vim.bo[after_buf].bufhidden = 'wipe'
    vim.bo[after_buf].modifiable = false
    vim.bo[after_buf].readonly = true
    vim.cmd.filetype('detect')
  end

  vim.wo[after_win].winhl = DIFF_HL.after
  vim.wo[after_win].winbar = 'After: ' .. path.name
  vim.cmd.diffthis()

  -- Ensure we're at the top of the diff, instead of some random position.
  vim.cmd('norm! gg')

  -- Just setting the sidebar width with nvim_win_set_width() doesn't seem to do
  -- the trick, so we have to resize it this way.
  api.nvim_set_current_win(STATE.status.win)
  vim.cmd('vert resize 25')

  -- Make sure the other window widths are also adjusted to fit properly.
  vim.cmd('wincmd =')

  STATE.diff_windows = { before_win, after_win }

  if api.nvim_win_is_valid(prev_win) then
    api.nvim_set_current_win(prev_win)
  else
    api.nvim_set_current_win(after_win)
  end
end

local function setup_sidebar()
  STATE.status.win = api.nvim_get_current_win()
  STATE.status.buf = api.nvim_create_buf(false, true)
  api.nvim_win_set_buf(STATE.status.win, STATE.status.buf)

  api.nvim_create_autocmd('BufWipeout', {
    group = AUGROUP,
    once = true,
    buffer = STATE.status.buf,
    callback = function(data)
      -- If the tab as a whole is closed using `:tabclose`, this event runs
      -- _first_ and `:tabclose` will in fact try to close the new tab. To
      -- prevent this, we wrap the closing in `vim.schedule()`.
      vim.schedule(function()
        close_diff_windows()
        STATE = {}
      end)
    end,
  })

  api.nvim_buf_set_name(STATE.status.buf, 'diff://status')
  vim.wo[STATE.status.win].winhl = 'CursorLine:' .. SIDEBAR_HL.cursor_line
  vim.wo[STATE.status.win].winbar = 'Status'
  vim.wo[STATE.status.win].winfixwidth = true
  vim.wo[STATE.status.win].number = false
  vim.wo[STATE.status.win].relativenumber = false
  vim.wo[STATE.status.win].statuscolumn = ''
  vim.wo[STATE.status.win].signcolumn = 'no'
  vim.wo[STATE.status.win].cursorline = true
  vim.wo[STATE.status.win].cursorlineopt = 'line'
  vim.bo[STATE.status.buf].buflisted = false
  vim.bo[STATE.status.buf].buftype = 'nofile'
  vim.bo[STATE.status.buf].bufhidden = 'wipe'
  vim.bo[STATE.status.buf].modifiable = false
  vim.bo[STATE.status.buf].readonly = true
end

local function update_sidebar_cursor_line()
  api.nvim_win_set_cursor(STATE.status.win, { STATE.file_index, 0 })
end

-- TODO: handle files that are both staged and unstaged (e.g. the file is
-- modified after being staged).
local function render_sidebar()
  STATE.file_lines = {}

  local grouped = {}

  for _, path in ipairs(STATE.paths) do
    local dir = fn.fnamemodify(path.name, ':h')

    if not grouped[dir] then
      grouped[dir] = {}
    end

    table.insert(grouped[dir], path)
  end

  local keys = vim.tbl_keys(grouped)

  table.sort(keys, function(a, b)
    return a < b
  end)

  local status_lines = {}
  local status_highlights = {}

  for _, dir in ipairs(keys) do
    table.insert(status_lines, ' ' .. dir)
    table.insert(
      status_highlights,
      { SIDEBAR_HL.directory, #status_lines - 1, 0, -1 }
    )

    table.sort(grouped[dir], function(a, b)
      return a.name < b.name
    end)

    for _, path in ipairs(grouped[dir]) do
      local prefix = '  '
      local staged_hl

      if STATE.staging and path.staged then
        prefix = prefix .. 'S '
        staged_hl = SIDEBAR_HL.staged
      elseif STATE.staging then
        prefix = prefix .. 'U '
        staged_hl = SIDEBAR_HL.unstaged
      end

      local line = prefix
        .. path.status
        .. ' '
        .. fn.fnamemodify(path.name, ':t')

      table.insert(status_lines, line)
      table.insert(
        status_highlights,
        { STATUS_HL[path.status], #status_lines - 1, #prefix, #prefix + 1 }
      )

      if STATE.staging then
        table.insert(status_highlights, { staged_hl, #status_lines - 1, 2, 3 })
      end

      STATE.file_lines[#status_lines] = path
    end
  end

  vim.bo[STATE.status.buf].modifiable = true
  vim.bo[STATE.status.buf].readonly = false
  api.nvim_buf_set_lines(STATE.status.buf, 0, -1, true, status_lines)
  vim.bo[STATE.status.buf].modifiable = false
  vim.bo[STATE.status.buf].readonly = true

  -- Now that all the lines are in place, we can add the buffer-local
  -- highlights.
  api.nvim_buf_clear_namespace(STATE.status.buf, NAMESPACE, 0, -1)

  for _, hl in ipairs(status_highlights) do
    api.nvim_buf_add_highlight(STATE.status.buf, NAMESPACE, unpack(hl))
  end
end

local function select_next_file(direction)
  local index = STATE.file_index + direction

  if not STATE.file_lines[index] then
    index = index + direction
  end

  local max_line = fn.line('$', STATE.status.win)

  if index > max_line then
    index = 2
  elseif index < 2 then
    index = max_line
  end

  STATE.file_index = index
  update_sidebar_cursor_line()
  render_diffs()
end

local function select_file()
  local line, _ = unpack(api.nvim_win_get_cursor(STATE.status.win))

  STATE.file_index = line
  render_diffs()
end

local function stage_file()
  local line, _ = unpack(api.nvim_win_get_cursor(STATE.status.win))
  local path = STATE.file_lines[line]

  if not path then
    return
  end

  if path.staged then
    git_unstage(STATE.root, path.name)
  else
    git_stage(STATE.root, path.name)
  end

  STATE.paths = git_status()
  render_sidebar()
  select_next_file(1)
end

local function undo_file()
  local line, _ = unpack(api.nvim_win_get_cursor(STATE.status.win))
  local path = STATE.file_lines[line]

  if not path then
    return
  end

  if path.staged then
    git_unstage(STATE.root, path.name)
  end

  git_undo(STATE.root, path.name)
  STATE.paths = git_status()
  render_sidebar()
  select_next_file(-1)
end

local function refresh()
  STATE.paths = git_status()
  STATE.file_index = INIT_INDEX
  render_sidebar()
  render_diffs()
  update_sidebar_cursor_line()
  render_diffs()
end

local function setup_sidebar_maps()
  local maps = {
    [CONFIG.select_file] = select_file,
    [CONFIG.next_file] = M.next_file,
    [CONFIG.prev_file] = M.previous_file,
  }

  if STATE.staging then
    maps[CONFIG.stage_file] = stage_file
    maps[CONFIG.undo_file] = undo_file
    maps[CONFIG.refresh] = refresh
  end

  for key, func in pairs(maps) do
    vim.keymap.set(
      'n',
      key,
      func,
      { buffer = STATE.status.buf, silent = true, noremap = true }
    )
  end
end

function M.show(start, stop)
  local parent
  local paths

  if STATE.root then
    util.error('the diff viewer is already active')
    return
  end

  if start and stop then
    parent = git_parent(start)
    paths = git_diff(start, stop)
  elseif start then
    parent = git_parent(start)
    paths = git_diff(parent, start)
    stop = start
  else
    parent = 'HEAD'
    paths = git_status()
  end

  if #paths == 0 then
    util.error('there are no files to diff')
    return
  end

  STATE = new_state(start, stop, parent, paths)

  vim.cmd.tabnew()
  setup_sidebar()
  setup_sidebar_maps()
  render_sidebar()
  update_sidebar_cursor_line()
  render_diffs()
end

function M.next_file()
  if STATE.root then
    select_next_file(1)
  end
end

function M.previous_file()
  if STATE.root then
    select_next_file(-1)
  end
end

return M
