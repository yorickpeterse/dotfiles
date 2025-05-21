local ts = require('nvim-treesitter')

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
