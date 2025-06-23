local ts = require('nvim-treesitter')
local installed = require('nvim-treesitter.config').get_installed()
local install = vim
  .iter({
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
  :filter(function(name)
    return not vim.tbl_contains(installed, name)
  end)
  :totable()

if #install > 0 then
  ts.install(install)
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
