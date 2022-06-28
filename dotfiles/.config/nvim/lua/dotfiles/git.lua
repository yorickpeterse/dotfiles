local M = {}
local api = vim.api
local cb = require('diffview.config').diffview_callback

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
      [']f'] = cb('select_next_entry'),
      ['[f'] = cb('select_prev_entry'),
    },
    file_panel = {
      ['j'] = cb('next_entry'),
      ['k'] = cb('prev_entry'),
      ['<CR>'] = cb('select_entry'),
      ['-'] = cb('toggle_stage_entry'),
      ['U'] = cb('unstage_all'),
      ['X'] = cb('restore_entry'),
      ['R'] = cb('refresh_files'),
      [']f'] = cb('select_next_entry'),
      ['[f'] = cb('select_prev_entry'),
    },
  },
})

return M
