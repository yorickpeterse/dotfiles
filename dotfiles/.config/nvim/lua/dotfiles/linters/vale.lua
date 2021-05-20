local lint = require('dotfiles.lint')
local util = require('dotfiles.lint.util')

local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
}

lint.linter('markdown', {
  name = 'vale',
  exe = function(path)
    return 'vale', { '--output', 'JSON', path }
  end,
  parse = function(output)
    local decoded = util.json_decode(output)
    local items = {}

    for _, file_items in pairs(decoded) do
      for _, item in ipairs(file_items) do
        table.insert(items, {
          source = 'vale',
          range = {
            ['start'] = {
              line = item.Line - 1,
              character = item.Span[1] - 1,
            },
            ['end'] = {
              line = item.Line - 1,
              character = item.Span[2] - 1,
            },
          },
          message = item.Message,
          severity = severities[item.Severity] or severities.warning,
        })
      end
    end

    return items
  end
})
