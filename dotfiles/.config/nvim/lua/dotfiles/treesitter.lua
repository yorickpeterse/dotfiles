local ts = require('nvim-treesitter')
local uv = vim.uv
local fn = vim.fn

-- Per https://github.com/nvim-treesitter/nvim-treesitter/issues/7872 it's
-- apparently a feature to always log even if there's nothing to be done, so
-- let's avoid calling install() if there are no changes made to this file. This
-- way I don't need to remember yet another command/step to run just to set up
-- an editing environment.
local install = true
local time = tostring(uv.fs_stat(debug.getinfo(1, 'S').source:sub(2)).mtime.sec)
local path = fn.stdpath('cache') .. '/dotfiles_treesitter.txt'
local file = io.open(path, 'r')

if file then
  local existing = file:read()

  file:close()

  if existing and existing == time then
    install = false
  end
end

if not file or install then
  local file = io.open(path, 'w')

  if file then
    file:write(time)
    file:close()
  end
end

if install then
  ts.install({
    'bash',
    'c',
    'css',
    'fish',
    'gitcommit',
    'go',
    'html',
    'inko',
    'javascript',
    'json',
    'llvm',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'ruby',
    'rust',
    'toml',
    'typst',
    'vimdoc',
    'yaml',
  })
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'bash',
    'c',
    'css',
    'fish',
    'gitcommit',
    'go',
    'help',
    'html',
    'inko',
    'javascript',
    'json',
    'llvm',
    'lua',
    'python',
    'query',
    'ruby',
    'rust',
    'sh',
    'toml',
    'typst',
    'yaml',
  },
  callback = function()
    vim.treesitter.start()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'python',
    'inko',
    'css',
  },
  callback = function()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
