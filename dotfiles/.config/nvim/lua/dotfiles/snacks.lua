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
      frecency = true,
    },
    toggles = {
      hidden = false,
    },
    win = {
      input = {
        keys = {
          ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
          ['<C-[>'] = { 'close', mode = { 'n', 'i' } },
          ['<Tab>'] = { 'list_down', mode = { 'n', 'i' } },
          ['<S-Tab>'] = { 'list_up', mode = { 'n', 'i' } },
          ['<C-p>'] = { 'toggle_preview', mode = { 'n', 'i' } },
          ['<C-d>'] = { 'bufdelete', mode = { 'n', 'i' } },
        },
      },
    },
    layouts = {
      select = {
        layout = {
          relative = 'cursor',
          row = 1,
          width = 0.25,
          min_with = 40,
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
