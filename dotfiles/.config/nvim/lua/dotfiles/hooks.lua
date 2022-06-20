local M = {}
local util = require('dotfiles.util')
local keycode = util.keycode
local fn = vim.fn
local lsp = vim.lsp
local api = vim.api
local comp = require('dotfiles.completion')
local diag = require('dotfiles.diagnostics')
local loclist = require('dotfiles.location_list')
local diff = require('dotfiles.diff')

-- The namespace to use for restoring cursors after formatting a buffer.
local format_mark_ns = api.nvim_create_namespace('')

local function au(name, commands)
  local group = api.nvim_create_augroup('dotfiles_' .. name, { clear = true })

  for _, command in ipairs(commands) do
    local event = command[1]
    local patt = command[2]
    local action = command[3]

    if type(action) == 'string' then
      api.nvim_create_autocmd(
        event,
        { pattern = patt, command = action, group = group }
      )
    else
      api.nvim_create_autocmd(
        event,
        { pattern = patt, callback = action, group = group }
      )
    end
  end
end

local function remove_trailing_whitespace()
  local line = fn.line('.')
  local col = fn.col('.')

  -- In .snippets files, a line may start with just a tab so snippets can
  -- include empty lines. In this case we don't want to remove the tab.
  if vim.bo.ft == 'snippets' then
    vim.cmd([[%s/ \+$//eg]])
  else
    vim.cmd([[%s/\s\+$//eg]])
  end

  fn.cursor(line, col)
end

local function yanked()
  vim.highlight.on_yank({
    higroup = 'Visual',
    timeout = 150,
    on_visual = false,
  })
end

local function format_buffer()
  if not util.has_lsp_clients() then
    return
  end

  local bufnr = api.nvim_win_get_buf(0)
  local windows = fn.win_findbuf(bufnr)
  local marks = {}

  -- Until https://github.com/neovim/neovim/issues/14645 is solved, I use this
  -- code to ensure the cursor position is properly restored after formatting a
  -- buffer. The approach used supports restoring cursors for different windows
  -- using the same buffer.
  for _, window in ipairs(windows) do
    local line, col = unpack(api.nvim_win_get_cursor(window))
    local ok, result = pcall(
      api.nvim_buf_set_extmark,
      bufnr,
      format_mark_ns,
      line - 1,
      col,
      {}
    )

    if ok then
      marks[window] = result
    end
  end

  lsp.buf.format({
    filter = function(client)
      return client.name ~= 'sumneko_lua'
    end,
    bufnr = bufnr,
    timeout_ms = 5000,
  })

  for _, window in ipairs(windows) do
    local mark = marks[window]

    local line, col = unpack(
      api.nvim_buf_get_extmark_by_id(bufnr, format_mark_ns, mark, {})
    )

    local max_line_index = api.nvim_buf_line_count(bufnr) - 1

    if line and col and line <= max_line_index then
      api.nvim_win_set_cursor(window, { line + 1, col })
    end
  end

  api.nvim_buf_clear_namespace(bufnr, format_mark_ns, 0, -1)
end

-- Moves back to the previous window when closing a quickfix window, unless we
-- closed the quickfix window from another window (e.g. using `:cclose`).
function M.close_quickfix()
  local closed_win = tonumber(fn.expand('<afile>'))
  local current_win = api.nvim_get_current_win()

  if closed_win == current_win then
    api.nvim_feedkeys(keycode('<C-w>p'), 'n', true)
  end
end

-- Opens a quickfix or location list item in the previous window, optionally
-- splitting it first.
function M.open_quickfix_item(split_cmd)
  local prev_win = 0
  local line = fn.line('.')
  local list = fn.getloclist(0, { items = 0, filewinid = 0 })
  local err_cmd = 'cc'

  if list.filewinid > 0 then
    -- The current window is a location list window.
    if #list.items == 0 then
      return
    end

    err_cmd = 'll'
    prev_win = list.filewinid
  else
    if #fn.getqflist() == 0 then
      return
    end

    prev_win = util.target_window(fn.win_getid(fn.winnr('#')))
  end

  api.nvim_set_current_win(prev_win)

  if split_cmd then
    vim.cmd(split_cmd)
  end

  vim.cmd(err_cmd .. line)
end

local function enable_list()
  vim.w.list_enabled = vim.wo.list
  vim.wo.list = false
end

local function disable_list()
  if vim.w.list_enabled ~= nil then
    vim.wo.list = vim.w.list_enabled
  end
end

-- Deletes empty anonymous buffers when hiding them, so they don't pile up.
local function remove_buffer()
  local buffer = fn.bufnr()
  local ft = api.nvim_buf_get_option(buffer, 'ft')

  if ft == 'qf' or ft == 'help' then
    return
  end

  if fn.bufname(buffer) ~= '' then
    return
  end

  local lines = fn.getbufline(buffer, 1, 1)

  if #lines == 0 or #lines[1] == 0 then
    -- The buffer is still in use at this point, so we must schedule the removal
    -- until after the hook finishes.
    vim.schedule(function()
      if fn.bufloaded(buffer) then
        pcall(api.nvim_buf_delete, buffer, {})
      end
    end)
  end
end

au('buffer_management', {
  { 'BufWinLeave', '*', remove_buffer },
})

au('completion', {
  { 'CompleteDonePre', '*', comp.done },
})

au('yank', {
  { 'TextYankPost', '*', yanked },
})

au('trailing_whitespace', {
  { 'BufWritePre', '*', remove_trailing_whitespace },
  { 'InsertEnter', '*', enable_list },
  { 'InsertLeave', '*', disable_list },
})

-- LSP and linting
au('lsp', {
  { 'BufWritePre', '*', format_buffer },
  { 'CursorMoved', '*', diag.echo_diagnostic },
  { 'CursorMoved', '*', diag.underline },
  { 'DiagnosticChanged', '*', diag.refresh },
  { 'BufWinEnter', '*', loclist.enter_window },
  { 'DiagnosticChanged', '*', loclist.diagnostics_changed },
})

au('diffs', {
  { 'BufAdd', 'fugitive://*', diff.fix_highlight },
  { 'BufEnter', 'diffview:///panels*', 'set cursorlineopt+=line' },
})

-- Automatically create leading directories when writing a file. This makes it
-- easier to create new files in non-existing directories.
au('create_dirs', {
  { 'BufWritePre', '*', "call mkdir(expand('<afile>:p:h'), 'p')" },
})

-- Open the quickfix window at the bottom when using `:grep`.
au('grep_quickfix', {
  { 'QuickFixCmdPost', 'grep', 'cwindow' },
})

-- Highlight all search matches while searching, but not when done searching.
au('search_highlight', {
  { 'CmdlineEnter', '[/?]', ':set hlsearch' },
  { 'CmdlineLeave', '[/?]', ':set nohlsearch' },
})

return M
