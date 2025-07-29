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
    match = function(items, indexes, query)
      local query = vim.split(
        vim.pesc(table.concat(query):lower()),
        '%s',
        { trimempty = true }
      )

      local matches = {}

      for _, idx in ipairs(indexes) do
        local search = items[idx]:lower()
        local match = true
        local len = 0

        for _, pat in ipairs(query) do
          local start, stop = search:find(pat)

          if not start then
            match = false
            break
          end

          len = len + (stop - start)
        end

        if match then
          table.insert(
            matches,
            { index = idx, text = items[idx], score = len / #search }
          )
        end
      end

      table.sort(matches, function(a, b)
        return (a.score == b.score) and (a.text < b.text) or (a.score > b.score)
      end)

      return vim.tbl_map(function(i)
        return i.index
      end, matches)
    end,
  },
})

vim.ui.select = pick.ui_select

-- This makes text objects like "i" work a bit better (e.g. for quotes spanning
-- multiple lines).
require('mini.ai').setup({
  silent = true,
})

require('mini.surround').setup({
  silent = true,
})
