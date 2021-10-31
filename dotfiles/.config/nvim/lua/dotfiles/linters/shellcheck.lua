local lint = require('dotfiles.lint')
local util = require('dotfiles.lint.util')

local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
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
        lnum = item.line - 1,
        end_lnum = item.endLine - 1,
        col = item.column - 1,
        end_col = item.endColumn - 1,
        severity = severities[item.level] or severities.warning,
        message = item.message,
      })
    end

    return items
  end,
})
