require('nvim-web-devicons').setup({
  override = {
    -- This defaults to white, which is unreadable.
    ['md'] = {
      icon = '',
      color = '#519aba',
      cterm_color = '67',
      name = 'Markdown',
    },
    ['inko'] = {
      icon = '󱗆',
      color = '#1c5708',
      name = 'Inko',
    },
  },
})
