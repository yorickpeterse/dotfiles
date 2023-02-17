require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'bash',
    'c',
    'fish',
    'go',
    'javascript',
    'json',
    'lua',
    'python',
    'ruby',
    'rust',
    'toml',
    'yaml',
  },
  sync_install = false,
  highlight = {
    enable = true,
    disable = { 'ruby', 'rust' },
    additional_vim_regex_highlighting = false,
  },
})
