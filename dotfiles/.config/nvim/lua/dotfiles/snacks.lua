local snacks = require('snacks')
local format = require('snacks.picker.format')

local function format_symbol(item, picker)
  local opts = picker.opts
  local ret = {}
  local kind = item.kind or 'Unknown'
  local kind_hl = 'SnacksPickerIcon' .. kind

  ret[#ret + 1] = { picker.opts.icons.kinds[kind], kind_hl }
  ret[#ret + 1] = { ' ' }

  local name = vim.trim(item.name:gsub('\r?\n', ' '))

  name = name == '' and item.detail or name
  snacks.picker.highlight.format(item, name, ret)

  local scope = item.parent and item.parent.text

  if scope and scope ~= 'root' then
    local len = 0

    for _, item in ipairs(picker.finder.items) do
      if item.text and #item.text > len then
        len = #item.text
      end
    end

    len = len + 4

    local offset = snacks.picker.highlight.offset(ret, { char_idx = true })

    ret[#ret + 1] = { snacks.picker.util.align(' ', len - offset) }
    ret[#ret + 1] = { item.parent.text, 'Comment' }
  end

  if opts.workspace then
    local offset = snacks.picker.highlight.offset(ret, { char_idx = true })

    ret[#ret + 1] = { snacks.picker.util.align(' ', 40 - offset) }
    vim.list_extend(ret, format.filename(item, picker))
  end

  return ret
end

snacks.setup({
  picker = {
    prompt = ' > ',
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
        format = format_symbol,
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
        format = format_symbol,
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
