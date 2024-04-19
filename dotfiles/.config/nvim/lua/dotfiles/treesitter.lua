require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'bash',
    'c',
    'fish',
    'go',
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
      -- Indent is only enabled for Python, such that no extra plugins are
      -- needed to get PEP8 indentation. For other languages indentation doesn't
      -- work very well, so we disable it there.
      return lang ~= 'python'
    end,
  },
})
