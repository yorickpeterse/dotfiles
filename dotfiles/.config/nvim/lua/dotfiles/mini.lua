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
  source = {
    match = function(items, indexes, query, opts)
      -- Inserting a space at the end results in mini.pick filtering out entries
      -- with only a partial match, cutting down the amount of noise (e.g.
      -- "test" no longer matches "types/src/format.rs").
      --
      -- We need to copy the query as modifying it in-place also modifies the
      -- way the query is displayed.
      local query = vim.deepcopy(query)

      table.insert(query, ' ')
      return MiniPick.default_match(items, indexes, query, opts)
    end,
  },
})

vim.ui.select = pick.ui_select

require('mini.git').setup({
  command = {
    split = 'vertical',
  },
})
