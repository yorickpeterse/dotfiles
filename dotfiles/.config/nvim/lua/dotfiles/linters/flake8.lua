local lint = require('dotfiles/lint')

local severities = {
  E = vim.lsp.protocol.DiagnosticSeverity.Error,
  W = vim.lsp.protocol.DiagnosticSeverity.Warning,
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
          range = {
            ['start'] = {
              line = tonumber(lnum) - 1,
              character = tonumber(column) - 1,
            },
            ['end'] = {
              line = tonumber(lnum) - 1,
              character = tonumber(column),
            }
          },
          message = message,
          severity = severities[kind] or severities.W
        })
      end
    end

    return items
  end
})
