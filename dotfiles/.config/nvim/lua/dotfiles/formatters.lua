require('conform').setup({
  formatters_by_ft = {
    fish = { 'fish_indent' },
    lua = { 'stylua' },
    python = { 'black' },
    zig = { 'zigfmt' },
  },
})
