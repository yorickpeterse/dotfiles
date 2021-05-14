-- Configuration for nvim-lint (https://github.com/mfussenegger/nvim-lint)

local lint = require('lint')

lint.linters_by_ft = vim.tbl_extend('force', lint.linters_by_ft, {
  -- gitcommit = { 'gitlint' },
  python = { 'flake8' },
  ruby = { 'ruby', 'rubocop' },
  sh = { 'shellcheck' },
})

-- vim: set foldmethod=marker
