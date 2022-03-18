local M = {}
local util = require('dotfiles.util')
local au = util.au
local keycode = util.keycode
local fn = vim.fn
local lsp = vim.lsp
local api = vim.api

-- The namespace to use for restoring cursors after formatting a buffer.
local format_mark_ns = api.nvim_create_namespace('')

function M.remove_trailing_whitespace()
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

function M.yanked()
  vim.highlight.on_yank({
    higroup = 'Visual',
    timeout = 150,
    on_visual = false,
  })
end

function M.format_buffer()
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

  lsp.buf.formatting_sync(nil, 5000)

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

function M.toggle_list(enter)
  if enter then
    vim.w.list_enabled = vim.wo.list
    vim.wo.list = false
  elseif vim.w.list_enabled ~= nil then
    vim.wo.list = vim.w.list_enabled
  end
end

-- Deletes empty anonymous buffers when hiding them, so they don't pile up.
function M.remove_buffer()
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
  'BufWinLeave * lua dotfiles.hooks.remove_buffer()',
})

au('completion', { 'CompleteDonePre * lua dotfiles.completion.done()' })

au('filetypes', {
  'BufRead,BufNewFile *.rll set filetype=rll',
  'BufRead,BufNewFile Dangerfile set filetype=ruby',
})

au('yank', { 'TextYankPost * lua dotfiles.hooks.yanked()' })

au('trailing_whitespace', {
  'BufWritePre * lua dotfiles.hooks.remove_trailing_whitespace()',
  'InsertEnter * lua dotfiles.hooks.toggle_list(true)',
  'InsertLeave * lua dotfiles.hooks.toggle_list(false)',
})

-- LSP and linting
au('lsp', {
  'BufWritePre * lua dotfiles.hooks.format_buffer()',
  'CursorMoved * lua dotfiles.diagnostics.echo_diagnostic()',
  'CursorMoved * lua dotfiles.diagnostics.underline()',
  'DiagnosticChanged * lua dotfiles.diagnostics.refresh()',
  'BufWinEnter * lua dotfiles.location_list.enter_window()',
  'DiagnosticChanged * lua dotfiles.location_list.diagnostics_changed()',
})

au('diffs', {
  'BufAdd fugitive://* lua require("dotfiles.diff").fix_highlight()',
  'BufEnter diffview:///panels* set cursorlineopt+=line',
})

-- Automatically create leading directories when writing a file. This makes it
-- easier to create new files in non-existing directories.
au('create_dirs', { "BufWritePre * call mkdir(expand('<afile>:p:h'), 'p')" })

-- Open the quickfix window at the bottom when using `:grep`.
au('grep_quickfix', { 'QuickFixCmdPost grep cwindow' })

-- Highlight all search matches while searching, but not when done searching.
au('search_highlight', {
  [[CmdlineEnter [/\?] :set hlsearch]],
  [[CmdlineLeave [/\?] :set nohlsearch]],
})

return M
