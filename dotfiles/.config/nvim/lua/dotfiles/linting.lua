local lint = require('lint')

lint.linters_by_ft = vim.tbl_extend('force', lint.linters_by_ft, {
  python = { 'flake8' },
  ruby = { 'ruby', 'rubocop' },
  sh = { 'shellcheck' },
})
