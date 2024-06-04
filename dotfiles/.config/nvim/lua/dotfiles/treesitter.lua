-- The languages for which to use Tree sitter indentation. Only a small list is
-- enabled as support is a bit of a hit and miss.
local indent = { python = true, inko = true, css = true }

require('nvim-treesitter.configs').setup({
  ensure_installed = {
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
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'ruby',
    'rust',
    'toml',
    'vimdoc',
    'yaml',
  },
  sync_install = false,
  highlight = {
    enable = true,
    disable = { 'ruby', 'c', 'markdown', 'markdown_inline' },
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    disable = function(lang, bufnr)
      return not indent[lang]
    end,
  },
})
