local lint = require('dotfiles.lint')
local util = require('dotfiles.lint.util')
local uv = vim.loop

local severities = {
  error = vim.diagnostic.severity.ERROR,
  fatal = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.WARN,
  convention = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.WARN,
}

-- Returns `true` if RuboCop is located in the given Gemfile.lock.
local function rubocop_in_gemfile(path)
  local fd = uv.fs_open(path, 'r', 0)

  if not fd then
    return false
  end

  local stat = uv.fs_stat(path)

  if not stat then
    uv.fs_close(fd)

    return false
  end

  local data = uv.fs_read(fd, stat.size)

  if not data then
    return false
  end

  uv.fs_close(fd)

  return data:match(' rubocop ') ~= nil
end

lint.linter('ruby', {
  name = 'rubocop',
  exe = function(path)
    local args = { 'rubocop', '--force-exclusion', '--format=json', path }
    local lockfile = util.find_file('Gemfile.lock')

    -- Only use `bundle exec` if RuboCop is in the Gemfile.
    if lockfile ~= '' and rubocop_in_gemfile(lockfile) then
      table.insert(args, 1, 'exec')
      table.insert(args, 1, 'bundle')
    end

    -- I use a small wrapper script that ensures RuboCop always runs using the
    -- correct Ruby version.
    return 'ruby-exec', args
  end,
  parse = function(output)
    local items = {}
    local decoded = util.json_decode(output)

    for _, file in ipairs(decoded.files or {}) do
      for _, diag in ipairs(file.offenses) do
        table.insert(items, {
          source = 'rubocop',
          lnum = diag.location.start_line - 1,
          end_lnum = diag.location.last_line - 1,
          col = diag.location.start_column - 1,
          end_col = diag.location.last_column,
          message = diag.message,
          severity = severities[diag.severity],
        })
      end
    end

    return items
  end,
})
