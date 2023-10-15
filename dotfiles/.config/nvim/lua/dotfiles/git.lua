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
  keymaps = {
    disable_defaults = true,
    view = {
      { 'n', ']f', actions.select_next_entry },
      { 'n', '[f', actions.select_prev_entry },
    },
    file_panel = {
      { 'n', 'j', actions.next_entry },
      { 'n', 'k', actions.prev_entry },
      { 'n', '<CR>', actions.select_entry },
      { 'n', '-', actions.toggle_stage_entry },
      { 'n', 'U', actions.unstage_all },
      { 'n', 'X', actions.restore_entry },
      { 'n', 'R', actions.refresh_files },
      { 'n', ']f', actions.select_next_entry },
      { 'n', '[f', actions.select_prev_entry },
    },
  },
})

return M
