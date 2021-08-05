local M = {}
local api = vim.api
local cb = require('diffview.config').diffview_callback

require('diffview').setup {
  diff_binaries = false,
  file_panel = {
    width = 40,
    use_icons = true
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
    }
  }
}

return M
