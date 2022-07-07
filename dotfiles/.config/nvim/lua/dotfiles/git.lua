local M = {}
local api = vim.api
local actions = require('diffview.actions')

require('diffview').setup({
  diff_binaries = false,
  enhanced_diff_hl = true,
  use_icons = true,
  file_panel = {
    win_config = {
      width = 40,
    },
  },
  key_bindings = {
    disable_defaults = true,
    view = {
      [']f'] = actions.select_next_entry,
      ['[f'] = actions.select_prev_entry,
    },
    file_panel = {
      ['j'] = actions.next_entry,
      ['k'] = actions.prev_entry,
      ['<CR>'] = actions.select_entry,
      ['-'] = actions.toggle_stage_entry,
      ['U'] = actions.unstage_all,
      ['X'] = actions.restore_entry,
      ['R'] = actions.refresh_files,
      [']f'] = actions.select_next_entry,
      ['[f'] = actions.select_prev_entry,
    },
  },
})

return M
