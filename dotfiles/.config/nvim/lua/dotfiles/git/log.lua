local fn = vim.fn
local api = vim.api
local util = require('dotfiles.util')
local diff = require('dotfiles.git.diff')
local M = {}

-- The highlight groups to use for various elements.
local HIGHLIGHTS = {
  commit = 'Yellow',
  author = 'Comment',
  date = 'Comment',
  addition = 'String',
  deletion = 'DiffDelete',
  title = 'Title',
  status = {
    A = 'DiffviewStatusAdded',
    D = 'DiffviewStatusDeleted',
    M = 'DiffviewStatusModified',
    ['?'] = 'Title',
  },
}

-- The format to use for dates.
local DATE_FORMAT = '%d %b %Y %H:%M'

-- The number of Git commits to get per call.
local LIMIT = 50

-- The minimum screen column width for the date marks to be displayed.
local DATE_MIN_COLUMNS = 100

-- The namespace to use for custom highlights and extmarks.
local NAMESPACE = api.nvim_create_namespace('dotfiles_git')

-- The group to use for the various buffer hooks.
local AUGROUP = api.nvim_create_augroup('dotfiles_git', { clear = true })

api.nvim_set_hl(NAMESPACE, 'CursorLine', { link = 'QuickFixLine' })

-- A boolean indicating if the module is active.
local ACTIVE = false

local function buffer_map(buf, mode, key, func)
  vim.keymap.set(
    mode,
    key,
    func,
    { buffer = buf, silent = true, noremap = true }
  )
end

local function git_log(opts)
  local opts = opts or {}
  local skip = (opts.offset or 0)
  local cmd = {
    'git',
    'log',
    '--format=%h\t%ad\t%aN\t%aE\t%cN\t%cE\t%s\t%p',
    '--date=format-local:' .. DATE_FORMAT,
    '--max-count=' .. LIMIT,
    '--skip=' .. skip,
  }

  if opts.search then
    table.insert(cmd, '--grep')
    table.insert(cmd, opts.search)
  end

  if opts.start then
    if opts.stop then
      table.insert(cmd, opts.start .. '...' .. opts.stop)
    else
      table.insert(cmd, opts.start)
    end
  end

  local res =
    vim.system(cmd, { text = true, env = { GIT_TERMINAL_PROMPT = '0' } }):wait()

  if res.code ~= 0 then
    util.error(vim.trim(res.stderr))
    return {}
  end

  local lines = vim.split(res.stdout, '\n', { trimempty = true })

  return vim
    .iter(lines)
    :map(function(line)
      local cols = vim.split(line, '\t', { trimempty = true })
      local subj = cols[7]
      local parents = {}

      if cols[8] then
        parents = vim.split(cols[8], ' ', { trimempty = true, plain = true })
      end

      return {
        id = cols[1],
        date = cols[2],
        author = {
          name = cols[3],
          email = cols[4],
        },
        committer = {
          name = cols[5],
          email = cols[6],
        },
        subject = subj,
        revert = vim.startswith(subj, 'Revert'),
        parents = parents,
      }
    end)
    :totable()
end

local function commit_body(sha)
  local res =
    vim.system({ 'git', 'show', '--quiet', '--format=%b', sha }):wait()

  assert(res.code == 0, 'Failed to run `git show`')

  return vim.split(res.stdout, '\n', { trimempty = true })
end

local function commit_files(sha)
  local res =
    vim.system({ 'git', 'show', '--name-status', '--format=', sha }):wait()

  assert(res.code == 0, 'Failed to run `git show`')

  local lines = vim.split(res.stdout, '\n', { trimempty = true })
  local files = {}

  for _, line in ipairs(lines) do
    local status, path = unpack(vim.split(line, '\t', { trimempty = true }))

    if status and path then
      files[path] = status
    end
  end

  return files
end

local function commit_stat(sha)
  local res = vim
    .system({ 'git', 'show', '--quiet', '--numstat', '--format=', sha })
    :wait()

  assert(res.code == 0, 'Failed to run `git show`')

  local lines = vim.split(res.stdout, '\n', { trimempty = true })
  local stats = {}
  local status = commit_files(sha)

  for _, line in ipairs(lines) do
    local adds, dels, file = unpack(vim.split(line, '\t', { trimempty = true }))

    table.insert(stats, {
      additions = tonumber(adds) or 0,
      deletions = tonumber(dels) or 0,
      file = file,
      status = status[file],
    })
  end

  table.sort(stats, function(a, b)
    return a.file < b.file
  end)

  return stats
end

local function add_lines(state)
  local lines = {}

  for line = state.offset, #state.commits do
    local commit = state.commits[line]
    local chunks = {
      { commit.id, HIGHLIGHTS.commit },
      { ' ', '' },
      { commit.author.name, HIGHLIGHTS.author },
      { ' ', '' },
      { commit.subject, '' },
    }

    if #commit.parents > 1 then
      table.insert(chunks, { '  Merge', 'WarningMsg' })
    end

    if commit.revert then
      table.insert(chunks, { '  Revert', 'ErrorMsg' })
    end

    table.insert(lines, chunks)
  end

  api.nvim_set_option_value('modifiable', true, { buf = state.buf })
  util.set_buffer_lines(state.buf, NAMESPACE, state.offset, -1, lines)
  api.nvim_set_option_value('modifiable', false, { buf = state.buf })
  api.nvim_set_option_value('modified', false, { buf = state.buf })
end

local function add_date_marks(state)
  for line, commit in ipairs(state.commits) do
    local date_id =
      api.nvim_buf_set_extmark(state.buf, NAMESPACE, line - 1, 0, {
        virt_text = {
          -- We add a bit of padding at the start so that if the mark covers
          -- other text, it won't look like the text is part of the date.
          { ' ', '' },
          { commit.date, HIGHLIGHTS.date },
        },
        virt_text_pos = 'right_align',
        hl_mode = 'combine',
      })

    table.insert(state.date_marks, date_id)
  end
end

local function remove_date_marks(state)
  for _, id in ipairs(state.date_marks) do
    api.nvim_buf_del_extmark(state.buf, NAMESPACE, id)
  end

  state.date_marks = {}
end

local function add_or_remove_date_marks(state)
  local width = api.nvim_win_get_width(state.win)
  local min = DATE_MIN_COLUMNS
  local num = #state.date_marks

  if width >= min and num == 0 then
    add_date_marks(state)
  elseif width < min and num > 0 then
    remove_date_marks(state)
  end
end

local function add_name_padding(state)
  local longest = 0

  for _, commit in ipairs(state.commits) do
    longest = math.max(longest, api.nvim_strwidth(commit.author.name))
  end

  -- This relies on extmarks so we don't have to update the entire line and mess
  -- around with the author highlights.
  for line, commit in ipairs(state.commits) do
    local mark = state.name_marks[line]
    local col = #commit.id + 1 + #commit.author.name
    local size = api.nvim_strwidth(commit.author.name)
    local pad = string.rep(' ', size < longest and (longest - size) or 0)

    local opts = {
      virt_text = { { pad, '' } },
      virt_text_pos = 'inline',
      hl_mode = 'combine',
    }

    -- If new commits are added, create the mark for them, otherwise we'll
    -- update the existing mark.
    if mark == nil then
      table.insert(
        state.name_marks,
        api.nvim_buf_set_extmark(state.buf, NAMESPACE, line - 1, col, opts)
      )
    else
      opts.id = mark
      api.nvim_buf_set_extmark(state.buf, NAMESPACE, line - 1, col, opts)
    end
  end
end

local function update(state)
  add_lines(state)
  add_or_remove_date_marks(state)
  add_name_padding(state)
end

local function reload(state)
  state.offset = 1
  state.commits =
    git_log({ offset = 0, start = state.start, stop = state.stop })

  remove_date_marks(state)
  update(state)
end

local function cursor_moved(state)
  local max = fn.line('$', state.win)
  local line, _ = unpack(api.nvim_win_get_cursor(state.win))

  if line < max or line == 1 then
    return false
  end

  local commits = git_log({
    start = state.start,
    stop = state.stop,
    offset = #state.commits,
    search = state.search,
  })

  if #commits == 0 then
    -- Once we've reached the end we disable this hook so we don't keep
    -- running redundant `git log` commands.
    return true
  end

  for _, commit in ipairs(commits) do
    table.insert(state.commits, commit)
  end

  state.offset = state.offset + #commits
  remove_date_marks(state)
  update(state)
end

local function format_person(person)
  return person.name .. ' <' .. person.email .. '>'
end

local function show_commit_diff(state)
  local line, _ = unpack(api.nvim_win_get_cursor(state.win))
  local commit = state.commits[line]

  if commit then
    diff.show(commit.id)
  end
end

local function toggle_commit_details(state)
  local line, _ = unpack(api.nvim_win_get_cursor(state.win))
  local commit = state.commits[line]

  if not commit then
    return
  end

  if state.commit.win == nil then
    vim.cmd.vnew()
    vim.cmd('vert res 85')
    state.commit.win = api.nvim_get_current_win()
    state.commit.buf = api.nvim_get_current_buf()
    api.nvim_set_current_win(state.win)

    util.set_window_option(state.commit.win, 'list', false)
    api.nvim_set_option_value('buftype', 'nofile', { buf = state.commit.buf })
    api.nvim_set_option_value('bufhidden', 'wipe', { buf = state.commit.buf })
    api.nvim_buf_set_name(state.commit.buf, 'Commit ' .. commit.id)

    local maps = {
      d = function()
        show_commit_diff(state)
      end,
      q = function()
        vim.cmd.tabclose()
      end,
    }

    for key, func in pairs(maps) do
      buffer_map(state.commit.buf, 'n', key, func)
    end

    api.nvim_create_autocmd('BufWipeout', {
      group = AUGROUP,
      buffer = state.commit.buf,
      callback = function(data)
        state.commit.id = nil
        state.commit.win = nil
        state.commit.buf = nil
      end,
    })
  elseif state.commit.id == commit.id then
    api.nvim_win_close(state.commit.win, true)
    return
  end

  state.commit.id = commit.id

  local body = commit_body(commit.id)
  local lines = {
    {
      { 'Author:    ', HIGHLIGHTS.title },
      { format_person(commit.author), '' },
    },
    {
      { 'Committer: ', HIGHLIGHTS.title },
      { format_person(commit.committer), '' },
    },
    {
      { 'Parents:   ', HIGHLIGHTS.title },
      { table.concat(commit.parents, ' '), HIGHLIGHTS.commit },
    },
    { { '', '' } },
    { { commit.subject, 'Title' } },
  }

  if #body > 0 then
    table.insert(lines, { { '', '' } })
  end

  for _, line in ipairs(body) do
    table.insert(lines, { { line, '' } })
  end

  table.insert(lines, { { '', '' } })

  local stat = commit_stat(commit.id)
  local max_file = 0

  for _, stat in ipairs(stat) do
    local size = api.nvim_strwidth(stat.file)

    if size > max_file then
      max_file = size
    end
  end

  table.insert(lines, { { 'Changes:', HIGHLIGHTS.title } })
  table.insert(lines, { { '', '' } })

  for _, stat in ipairs(stat) do
    local pad = max_file - api.nvim_strwidth(stat.file)
    local status = stat.status or '?'
    local line = {
      { status, HIGHLIGHTS.status[status] },
      { ' ', '' },
      { stat.file .. string.rep(' ', pad), '' },
    }

    if status == 'M' then
      table.insert(line, { '  ', '' })
      table.insert(
        line,
        { string.format('%-4d', stat.additions), HIGHLIGHTS.addition }
      )

      table.insert(line, { ' ', '' })
      table.insert(
        line,
        { string.format('%-4d', stat.deletions), HIGHLIGHTS.deletion }
      )
    end

    table.insert(lines, line)
  end

  api.nvim_buf_clear_namespace(state.commit.buf, NAMESPACE, 0, -1)
  api.nvim_set_option_value('modifiable', true, { buf = state.commit.buf })
  util.set_buffer_lines(state.commit.buf, NAMESPACE, 0, -1, lines)
  api.nvim_set_option_value('modifiable', false, { buf = state.commit.buf })
  api.nvim_set_option_value('modified', false, { buf = state.commit.buf })
end

local function revert_commit(state)
  local line, _ = unpack(api.nvim_win_get_cursor(state.win))
  local commit = state.commits[line]

  if not commit then
    return
  end

  if not util.confirm('Revert commit ' .. commit.id) then
    return
  end

  vim.system({ 'git', 'revert', '--edit', commit.id }, function(res)
    if res.code == 0 then
      vim.schedule(function()
        reload(state)
      end)
    else
      util.error(vim.trim(res.stderr))
    end
  end)
end

local function rebase_commits(state)
  local line, _ = unpack(api.nvim_win_get_cursor(state.win))

  if not state.commits[line] then
    return
  end

  if not util.confirm('Rebase the last ' .. line .. ' commit(s)') then
    return
  end

  vim.system(
    { 'git', 'rebase', '--interactive', 'HEAD~' .. line },
    { env = { GIT_EDITOR = EDITOR } },
    function(res)
      if res.code == 0 then
        vim.schedule(function()
          reload(state)
        end)
      else
        util.error(vim.trim(res.stderr))
      end
    end
  )
end

local function search_commits(state)
  state.search = fn.input('Search commits: ')

  if state.search == '' then
    reload(state)
  else
    state.offset = 1
    state.commits = git_log({
      offset = 0,
      start = state.start,
      stop = state.stop,
      search = state.search,
    })
    remove_date_marks(state)
    update(state)
  end

  api.nvim_echo({}, false, {})
end

function M.open(start, stop)
  if ACTIVE then
    util.error('the window is already active')
    return
  end

  vim.cmd.tabnew()
  ACTIVE = true

  local state = {
    start = start,
    stop = stop,
    search = '',
    commits = git_log({ offset = 0, start = start, stop = stop }),
    offset = 1,
    win = api.nvim_get_current_win(),
    buf = api.nvim_get_current_buf(),
    date_marks = {},
    name_marks = {},
    commit = {
      id = nil,
      buf = nil,
      win = nil,
    },
    commit_bodies = {},
  }

  api.nvim_set_option_value('buftype', 'nofile', { buf = state.buf })
  api.nvim_set_option_value('bufhidden', 'wipe', { buf = state.buf })
  api.nvim_buf_set_name(state.buf, 'Git log')

  util.set_window_option(state.win, 'cursorline', true)
  util.set_window_option(state.win, 'cursorlineopt', 'number,line')
  util.set_window_option(state.win, 'scrolloff', 2)
  api.nvim_win_set_hl_ns(state.win, NAMESPACE)
  update(state)

  local maps = {
    ['<CR>'] = function()
      toggle_commit_details(state)
    end,
    d = function()
      show_commit_diff(state)
    end,
    r = function()
      revert_commit(state)
    end,
    R = function()
      rebase_commits(state)
    end,
    ['/'] = function()
      search_commits(state)
    end,
  }

  for key, func in pairs(maps) do
    buffer_map(state.buf, 'n', key, func)
  end

  local resize_hook = api.nvim_create_autocmd('WinResized', {
    group = AUGROUP,
    pattern = tostring(state.win),
    callback = function()
      add_or_remove_date_marks(state)
    end,
  })

  api.nvim_create_autocmd('BufWipeout', {
    group = AUGROUP,
    buffer = state.buf,
    callback = function(data)
      api.nvim_del_autocmd(resize_hook)
      ACTIVE = false
    end,
  })

  api.nvim_create_autocmd('CursorMoved', {
    group = AUGROUP,
    buffer = state.buf,
    callback = function()
      cursor_moved(state)
    end,
  })
end

return M
