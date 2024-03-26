require('conform').setup({
  formatters = {
    inko = {
      meta = {
        url = 'https://inko-lang.org/',
        description = 'Format Inko source code according to the Inko style guide',
      },
      command = 'inko',
      args = { 'fmt', '-' },
    },
  },
  formatters_by_ft = {
    fish = { 'fish_indent' },
    lua = { 'stylua' },
    python = { 'black' },
    zig = { 'zigfmt' },
    inko = { 'inko' },
  },
})
