local lint = require('dotfiles.lint')

local severities = {
  E = vim.diagnostic.severity.ERROR,
  W = vim.diagnostic.severity.WARN,
}

lint.linter('python', {
  name = 'flake8',
  exe = function(path)
    return 'flake8', { path }
  end,
  parse = function(output)
    local items = {}

    for line in vim.gsplit(output, '\n') do
      local lnum, column, kind, message =
        line:match('[^:]+:(%d+):(%d+): ([A-Z]+)%d+ (.+)')

      if lnum and message then
        table.insert(items, {
          source = 'flake8',
          lnum = tonumber(lnum) - 1,
          end_lnum = tonumber(lnum) - 1,
          col = tonumber(column) - 1,
          end_col = tonumber(column),
          message = message,
          severity = severities[kind] or severities.W,
        })
      end
    end

    return items
  end,
})
