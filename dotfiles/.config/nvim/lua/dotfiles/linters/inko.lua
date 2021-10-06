local lint = require('dotfiles.lint')
local util = require('dotfiles.lint.util')

local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
}

-- Inko unit tests require the inclusion of an extra directory, otherwise we
-- won't be able to find some of the files imported into unit tests.
local function tests_directory()
  local path = util.buffer_path()
  local find = '/tests/test/'

  if not path:match(find) then
    return
  end

  local tests_dir = util.find_nearest_directory('tests')

  return tests_dir
end

lint.linter('inko', {
  name = 'inko',
  exe = function(path)
    local args = { 'build', '--format', 'json', '--check', path }
    local tests = tests_directory()
    local cmd = 'inko'

    if tests then
      table.insert(args, '--include')
      table.insert(args, tests)
    end

    -- When developing Inko itself, use a locally built executable; if
    -- available.
    if util.buffer_path():match('/runtime/') then
      local dev_cmd = util.find_file('target/release/inko')

      if dev_cmd ~= '' then
        cmd = dev_cmd
      end
    end

    return cmd, args
  end,
  stream = 'stderr',
  parse = function(output)
    local items = {}
    local decoded = util.json_decode(output)
    local bufpath = util.buffer_path()

    for _, diag in ipairs(decoded) do
      if diag.file == bufpath then
        table.insert(items, {
          source = 'inko',
          lnum = diag.line - 1,
          end_lnum = diag.line - 1,
          col = diag.column - 1,
          end_col = diag.column,
          message = diag.message,
          severity = severities[diag.level],
        })
      end
    end

    return items
  end
})
