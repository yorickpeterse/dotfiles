require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
    disable = { 'ruby', 'rust' },
    additional_vim_regex_highlighting = false,
  },
})
