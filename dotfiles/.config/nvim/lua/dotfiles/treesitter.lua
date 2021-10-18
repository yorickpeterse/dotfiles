require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    disable = { 'ruby' },
    additional_vim_regex_highlighting = false,
  },
}
