require('snacks').setup({
  picker = {
    prompt = ' > ',
    layout = {
      preset = 'vertical',
      preview = false,
      layout = {
        height = 0.5,
        title = '',
      },
    },
    matcher = {
      fuzzy = false,
    },
    toggles = {
      hidden = false,
    },
    win = {
      input = {
        keys = {
          ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
          ['<C-{>'] = { 'close', mode = { 'n', 'i' } },
          ['<Tab>'] = { 'list_down' },
          ['<S-Tab>'] = { 'list_up' },
          ['<C-p>'] = { 'toggle_preview' },
          ['<C-d>'] = { 'bufdelete', mode = { 'n', 'i' } },
        },
      },
    },
  },
  input = {
    icon = false,
    prompt_pos = 'title',
  },
  styles = {
    input = {
      title_pos = 'left',
      relative = 'cursor',
      row = 1,
      keys = {
        n_esc = { '<Esc>', { 'cancel' }, mode = 'n', expr = true },
        i_esc = { '<Esc>', { 'cancel' }, mode = 'i', expr = true },
      },
    },
  },
})
