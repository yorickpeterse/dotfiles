local pick = require('mini.pick')

require('mini.icons').setup({
  lsp = {
    ['function'] = { glyph = '󰊕' },
    ['method'] = { glyph = '󰊕' },
  },
})

pick.setup({
  mappings = {
    toggle_info = '<C-k>',
    toggle_preview = '<C-p>',
    move_down = '<Tab>',
    move_up = '<S-Tab>',
  },
  window = {
    config = function()
      local lines = vim.o.lines
      local cols = vim.o.columns
      local height = math.floor(0.6 * lines)
      local width = math.floor(0.6 * cols)

      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (lines - height)) - 1,
        col = math.floor(0.5 * (cols - width)),
      }
    end,
  },
})

vim.ui.select = pick.ui_select

-- This makes text objects like "i" work a bit better (e.g. for quotes spanning
-- multiple lines).
require('mini.ai').setup({
  silent = true,
})
