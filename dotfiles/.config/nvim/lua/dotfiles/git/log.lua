local fn = vim.fn
local api = vim.api
local util = require('dotfiles.util')
local M = {}

-- The highlight groups to use for various elements.
local HIGHLIGHTS = {
  commit = 'Yellow',
  author = 'Comment',
  date = 'Comment',
}

-- The number of Git commits to get per call.
local LIMIT = 25

-- The minimum screen column width for the extmarks to be displayed.
local MARKS_MIN_COLUMNS = 100

-- The namespace to use for custom highlights and extmarks.
local NAMESPACE = api.nvim_create_namespace('dotfiles_git')

-- The group to use for the various buffer hooks.
local AUGROUP = api.nvim_create_augroup('dotfiles_git', { clear = true })

api.nvim_set_hl(NAMESPACE, 'CursorLine', { link = 'QuickFixLine' })

local function git_log(opts)
  local opts = opts or {}
  local skip = (opts.offset or 0)

  local res = vim
    .system({
      'git',
      'log',
      '--format=%h\t%ad\t%aN\t%s\t%p',
      '--date=format-local:%d %b %Y %H:%M',
      '--max-count=' .. LIMIT,
      '--skip=' .. skip,
    }, { text = true, env = { GIT_TERMINAL_PROMPT = '0' } })
    :wait()

  assert(res.code == 0, 'Failed to run `git log`')

  local lines = vim.split(res.stdout, '\n', { trimempty = true })

  return vim.tbl_map(function(line)
    local cols = vim.split(line, '\t', { trimempty = true })
    local subj = cols[4]
    local parents = vim.split(cols[5], ' ', { trimempty = true, plain = true })

    return {
      id = cols[1],
      date = cols[2],
      author = cols[3],
      subject = subj,
      revert = vim.startswith(subj, 'Revert'),
      parents = parents,
    }
  end, lines)
end

local function add_highlights(state)
  for line = state.offset, #state.commits do
    local commit = state.commits[line]

    api.nvim_buf_add_highlight(
      state.buf,
      NAMESPACE,
      HIGHLIGHTS.commit,
      line - 1,
      0,
      #commit.id
    )

    api.nvim_buf_add_highlight(
      state.buf,
      NAMESPACE,
      HIGHLIGHTS.author,
      line - 1,
      #commit.id + 1,
      #commit.id + 1 + #commit.author
    )
  end
end

local function add_lines(state)
  local lines = {}

  for i = state.offset, #state.commits do
    local commit = state.commits[i]

    table.insert(
      lines,
      table.concat({ commit.id, commit.author, commit.subject }, ' ')
    )
  end

  api.nvim_set_option_value('modifiable', true, { buf = state.buf })
  api.nvim_buf_set_lines(state.buf, state.offset - 1, -1, false, lines)
  api.nvim_set_option_value('modifiable', false, { buf = state.buf })
  api.nvim_set_option_value('modified', false, { buf = state.buf })
end

local function add_marks(state)
  for line, commit in ipairs(state.commits) do
    local date_id =
      api.nvim_buf_set_extmark(state.buf, NAMESPACE, line - 1, 0, {
        virt_text = { { commit.date, HIGHLIGHTS.date } },
        virt_text_pos = 'right_align',
        hl_mode = 'combine',
      })

    table.insert(state.metadata_marks, date_id)

    local commit_markers = {}

    if #commit.parents > 1 then
      table.insert(commit_markers, { ' Merge', 'WarningMsg' })
    end

    if commit.revert then
      table.insert(commit_markers, { ' Revert', 'ErrorMsg' })
    end

    if #commit_markers > 0 then
      local text = {}

      for i, marker in ipairs(commit_markers) do
        if #commit_markers > 1 and i > 1 then
          table.insert(text, { ' ', '' })
        end

        table.insert(text, marker)
      end

      local id = api.nvim_buf_set_extmark(state.buf, NAMESPACE, line - 1, 0, {
        virt_text = text,
        virt_text_pos = 'eol',
        hl_mode = 'combine',
      })

      table.insert(state.metadata_marks, id)
    end
  end
end

local function remove_marks(state)
  for _, id in ipairs(state.metadata_marks) do
    api.nvim_buf_del_extmark(state.buf, NAMESPACE, id)
  end

  state.metadata_marks = {}
end

local function add_or_remove_marks(state)
  local width = api.nvim_win_get_width(state.win)
  local min = MARKS_MIN_COLUMNS
  local num = #state.metadata_marks

  if width >= min and num == 0 then
    add_marks(state)
  elseif width < min and num > 0 then
    remove_marks(state)
  end
end

local function add_name_padding(state)
  local longest = 0

  for _, commit in ipairs(state.commits) do
    longest = math.max(longest, api.nvim_strwidth(commit.author))
  end

  -- This relies on extmarks so we don't have to update the entire line and mess
  -- around with the author highlights.
  for line, commit in ipairs(state.commits) do
    local mark = state.name_marks[line]
    local col = #commit.id + 1 + #commit.author
    local size = api.nvim_strwidth(commit.author)
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
  add_or_remove_marks(state)
  add_name_padding(state)
  add_highlights(state)
end

function M.open()
  vim.cmd.tabnew()

  local state = {
    commits = git_log({ offset = 0 }),
    offset = 1,
    win = api.nvim_get_current_win(),
    buf = api.nvim_get_current_buf(),
    metadata_marks = {},
    name_marks = {},
  }

  api.nvim_set_option_value('buftype', 'nofile', { buf = state.buf })
  api.nvim_set_option_value('bufhidden', 'wipe', { buf = state.buf })
  api.nvim_buf_set_name(state.buf, 'Git log')

  util.set_window_option(state.win, 'cursorline', true)
  util.set_window_option(state.win, 'cursorlineopt', 'number,line')
  api.nvim_win_set_hl_ns(state.win, NAMESPACE)
  update(state)

  local resize_hook = api.nvim_create_autocmd('WinResized', {
    group = AUGROUP,
    pattern = tostring(state.win),
    callback = function()
      add_or_remove_marks(state)
    end,
  })

  api.nvim_create_autocmd('BufWipeout', {
    group = AUGROUP,
    buffer = state.buf,
    callback = function(data)
      api.nvim_del_autocmd(resize_hook)
    end,
  })

  api.nvim_create_autocmd('CursorMoved', {
    group = AUGROUP,
    buffer = state.buf,
    callback = function()
      local max = fn.line('$', state.win)
      local line, _ = unpack(api.nvim_win_get_cursor(state.win))

      if line < max then
        return false
      end

      local commits = git_log({ offset = #state.commits })

      if #commits == 0 then
        -- Once we've reached the end we disable this hook so we don't keep
        -- running redundant `git log` commands.
        return true
      end

      for _, commit in ipairs(commits) do
        table.insert(state.commits, commit)
      end

      state.offset = state.offset + #commits
      remove_marks(state)
      update(state)
    end,
  })
end

return M
