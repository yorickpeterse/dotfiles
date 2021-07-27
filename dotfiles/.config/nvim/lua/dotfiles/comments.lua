vim.g.kommentary_create_default_mappings = false

require('kommentary.config').configure_language('default', {
  prefer_single_line_comments = true,
  use_consistent_indentation = true
})
