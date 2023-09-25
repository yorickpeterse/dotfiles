local util = require('dotfiles.util')
local keycode = util.keycode
local fn = vim.fn
local lsp = vim.lsp
local api = vim.api
local diag = require('dotfiles.diagnostics')
local loclist = require('dotfiles.location_list')
local lint = require('lint')
local conform = require('conform')

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
    vim.cmd([[silent! %s/ \+$//eg]])
  else
    vim.cmd([[silent! %s/\s\+$//eg]])
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
  conform.format({
    bufnr = tonumber(fn.expand('<abuf>')),
    timeout_ms = 5000,
    lsp_fallback = true,
    quiet = true,
    filter = function(client)
      return client.name ~= 'sumneko_lua'
    end,
  })
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
  local buffer = api.nvim_get_current_buf()

  -- Only remove the buffer if the buffer being closed is the buffer that was
  -- active.
  if buffer ~= tonumber(fn.expand('<abuf>')) then
    return
  end

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

local function create_dirs(info)
  if not vim.startswith(info.match, 'oil:') then
    fn.mkdir(fn.expand('<afile>:p:h'), 'p')
  end
end

local function lint_buffer()
  lint.try_lint()
end

au('buffer_management', {
  { 'BufWinLeave', '*', remove_buffer },
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
  { 'BufWritePost', '*', lint_buffer },
})

au('diffs', {
  { 'BufEnter', 'diffview:///panels*', 'set cursorlineopt+=line' },
})

-- Automatically create leading directories when writing a file. This makes it
-- easier to create new files in non-existing directories.
au('create_dirs', {
  { 'BufWritePre', '*', create_dirs },
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
