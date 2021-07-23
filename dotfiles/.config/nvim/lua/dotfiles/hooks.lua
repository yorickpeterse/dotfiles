local function au(name, commands)
  local cmds = {}

  for _, cmd in ipairs(commands) do
    table.insert(cmds, 'au ' .. cmd)
  end

  local cmd = table.concat({
    'augroup dotfiles_',
    name,
    "\n",
    "autocmd!\n",
    table.concat(cmds, "\n"),
    "\n",
    'augroup END'
  })

  vim.cmd(cmd)
end

au('completion', { 'CompleteDonePre * lua dotfiles.completion.done()' })

au('filetypes', {
  'BufRead,BufNewFile *.rll set filetype=rll',
  'BufRead,BufNewFile Dangerfile set filetype=ruby'
})

-- FZF
au('fzf', { 'User FzfStatusLine lua dotfiles.callbacks.fzf_statusline()' })

-- Highlight yanked selections
au('yank', { 'TextYankPost * lua dotfiles.callbacks.yanked()' })

-- Remove and highlight trailing whitespace
au('trailing_whitespace', {
  [[BufWritePre * lua dotfiles.callbacks.remove_trailing_whitespace()]],
  [[BufWinEnter * match Visual /\s\+$/]],
  [[InsertEnter * match Visual /\s\+\%#\@<!$/]],
  [[InsertLeave * match Visual /\s\+$/]],
  [[BufWinLeave * call clearmatches()]],
})

-- LSP and linting
au('lsp', {
  'BufWritePre *.rs lua dotfiles.callbacks.format_buffer()',
  'BufWritePre *.go lua dotfiles.callbacks.format_buffer()',
  'CursorMoved * lua dotfiles.diagnostics.echo_diagnostic()',
  'BufWritePost * lua dotfiles.lint.lint()'
})

-- Fix diff highlights in fugitive
au('fugitive', { 'BufAdd fugitive://* lua dotfiles.diff.fix_highlight()' })

-- Automatically create leading directories when writing a file. This makes it
-- easier to create new files in non-existing directories.
au('create_dirs', { "BufWritePre * call mkdir(expand('<afile>:p:h'), 'p')" })

-- Open the quickfix window at the bottom when using `:grep`.
au('grep_quickfix', { 'QuickFixCmdPost grep cwindow' })

-- Highlight all search matches while searching, but not when done searching.
au('search_highlight', {
  [[CmdlineEnter [/\?] :set hlsearch]],
  [[CmdlineLeave [/\?] :set nohlsearch]]
})
