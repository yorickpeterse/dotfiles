local snacks = require('snacks')
local fmt = require('dotfiles.snacks.formatters')

snacks.setup({
  picker = {
    prompt = ' > ',
    icons = {
      files = {
        enabled = false,
      },
    },
    layout = {
      preview = false,
      layout = {
        backdrop = false,
        height = 0.6,
        width = 0.6,
        box = 'vertical',
        border = 'rounded',
        title = '',
        title_pos = 'center',
        { win = 'input', height = 1, border = 'bottom' },
        { win = 'list', border = '' },
        { win = 'preview', title = '', height = 0.5, border = 'top' },
      },
    },
    formatters = {
      file = {
        icon_width = 3,
      },
    },
    matcher = {
      fuzzy = false,
      frecency = false,
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
      preview = {
        wo = {
          number = false,
          relativenumber = false,
          signcolumn = 'no',
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
    sources = {
      lsp_symbols = {
        format = fmt.scoped_symbol,
        tree = false,
        filter = {
          default = {
            'Class',
            'Constructor',
            'Enum',
            'EnumMember',
            'Field',
            'Function',
            'Interface',
            'Method',
            'Module',
            'Namespace',
            'Package',
            'Property',
            'Struct',
            'Trait',
          },
        },
      },
      treesitter = {
        format = fmt.scoped_symbol,
        tree = false,
        filter = {
          default = {
            'Class',
            'Constant',
            'Enum',
            'Field',
            'Function',
            'Method',
            'Module',
            'Namespace',
            'Struct',
            'Trait',
          },
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
