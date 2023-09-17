local lint = require('lint')
local parser = require('lint.parser')
local util = require('dotfiles.util')
local api = vim.api
local fs = vim.fs
local fn = vim.fn

lint.linters_by_ft = {
  gitcommit = { 'gitlint' },
  inko = { 'inko' },
  markdown = { 'vale' },
  python = { 'flake8' },
  sh = { 'shellcheck' },
}

lint.linters.gitlint = {
  cmd = 'gitlint',
  stdin = false,
  append_fname = true,
  args = { '--ignore-stdin', '--msg-filename' },
  stream = 'stderr',
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local bufname = api.nvim_buf_get_name(bufnr)
    local root = fs.dirname(fs.dirname(bufname))

    if not util.file_exists(root .. '/' .. '.gitlint') then
      return {}
    end

    local parse = parser.from_pattern(
      '(%d+): %w+ ([^:]+)',
      { 'lnum', 'message' },
      {},
      {},
      {}
    )

    return parse(output, bufnr)
  end,
}

do
  local function include_tests()
    local path = fn.expand('%:p')
    local test = util.find_directory('test', path)

    if vim.startswith(path, test) and test ~= '' then
      return '--include=' .. test
    else
      return nil
    end
  end

  local severities = {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
  }

  lint.linters.inko = {
    cmd = 'inko',
    stdin = false,
    append_fname = true,
    args = { 'check', '--format=json', include_tests },
    stream = 'stderr',
    ignore_exitcode = true,
    parser = function(output, bufnr)
      local bufname = api.nvim_buf_get_name(bufnr)
      local diagnostics = {}

      if fn.filereadable(bufname) == 0 then
        return diagnostics
      end

      local items = vim.json.decode(output) or {}

      for _, diag in ipairs(items) do
        table.insert(diagnostics, {
          source = 'inko',
          lnum = diag.lines[1] - 1,
          end_lnum = diag.lines[2] - 1,
          col = diag.columns[1] - 1,
          end_col = diag.columns[2],
          severity = severities[diag.level],
          message = diag.message,
        })
      end

      return diagnostics
    end,
  }
end

-- Vale errors when a config file is missing, which is annoying for projects
-- that don't use Vale, so we just ignore the exit code.
lint.linters.vale.ignore_exitcode = true
