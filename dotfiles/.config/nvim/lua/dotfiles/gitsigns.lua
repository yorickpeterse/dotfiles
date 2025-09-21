local gitsigns = require('gitsigns')

gitsigns.setup({
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
  },
  signs_staged = {
    add = { text = '▍' },
    change = { text = '▍' },
  },
  signcolumn = true,
  update_debounce = 250,
  on_attach = function(buf)
    local function map(mode, l, r)
      vim.keymap.set(mode, l, r, { buffer = buf })
    end

    -- These maps are added here so we don't enable them for regular diff
    -- buffers that aren't handled by gitsigns (e.g. they don't match any files
    -- in a Git repository).
    map('n', ']c', function()
      gitsigns.nav_hunk('next', { target = 'all' })
    end)

    map('n', '[c', function()
      gitsigns.nav_hunk('prev', { target = 'all' })
    end)
  end,
})
