local lint = require('dotfiles.lint')
local util = require('dotfiles.lint.util')

local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
}

lint.linter('sh', {
  name = 'shellcheck',
  exe = function(path)
    return 'shellcheck', { '--format', 'json', path }
  end,
  parse = function(output)
    local decoded = util.json_decode(output)
    local items = {}

    for _, item in ipairs(decoded) do
      table.insert(items, {
        source = 'shellcheck',
        range = {
          ['start'] = {
            line = item.line - 1,
            character = item.column - 1,
          },
          ['end'] = {
            line = item.endLine - 1,
            character = item.endColumn - 1,
          },
        },
        severity = severities[item.level] or severities.warning,
        message = item.message,
      })
    end

    return items
  end
})
