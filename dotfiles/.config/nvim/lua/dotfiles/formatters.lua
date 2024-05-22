require('conform').setup({
  log_level = vim.log.levels.OFF,
  formatters_by_ft = {
    fish = { 'fish_indent' },
    lua = { 'stylua' },
    python = { 'black' },
    zig = { 'zigfmt' },
    inko = { 'inko' },
  },
})
