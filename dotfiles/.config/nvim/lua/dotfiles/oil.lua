require('oil').setup({
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  columns = {},
  buf_options = {
    bufhidden = 'wipe',
  },
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ['g?'] = 'actions.show_help',
    ['<CR>'] = 'actions.select',
    ['<C-r>'] = 'actions.refresh',
    ['-'] = 'actions.parent',
    ['_'] = 'actions.open_cwd',
    ['`'] = 'actions.cd',
    ['~'] = 'actions.tcd',
    ['gs'] = 'actions.change_sort',
    ['gx'] = 'actions.open_external',
    ['g.'] = 'actions.toggle_hidden',
  },
  use_default_keymaps = false,
})
