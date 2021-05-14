-- Configuration for nvim-lint (https://github.com/mfussenegger/nvim-lint)

local lint = require('lint')
local lsp_severities = vim.lsp.protocol.DiagnosticSeverity

lint.linters_by_ft = {
  markdown = { 'vale' },
  python = { 'flake8' },
  ruby = { 'ruby' },
  sh = { 'shellcheck' },
  text = {},
}

-- vim: set foldmethod=marker
