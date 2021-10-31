local lint = require('dotfiles.lint')
local util = require('dotfiles.lint.util')

local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
}

lint.linter('markdown', {
  name = 'vale',
  exe = function(path)
    return 'vale', { '--output', 'JSON', path }
  end,
  enable = function()
    return util.find_file('.vale.ini') ~= ''
  end,
  parse = function(output)
    local decoded = util.json_decode(output)
    local items = {}

    for _, file_items in pairs(decoded) do
      for _, item in ipairs(file_items) do
        table.insert(items, {
          source = 'vale',
          lnum = item.Line - 1,
          end_lnum = item.Line - 1,
          col = item.Span[1] - 1,
          end_col = item.Span[2] - 1,
          message = item.Message,
          severity = severities[item.Severity] or severities.warning,
        })
      end
    end

    return items
  end,
})
