local lint = require('dotfiles.lint')
local severities = vim.lsp.protocol.DiagnosticSeverity

lint.linter('ruby', {
  name = 'ruby',
  exe = function(path)
    return 'ruby', { '-w', '-c', path }
  end,
  stream = 'stderr',
  parse = function(output)
    local items = {}

    for line in vim.gsplit(output, '\n') do
      -- `ruby -c` produces two kinds of messages:
      --
      -- /tmp/test.rb:1: warning: possibly useless use of + in void context
      -- /tmp/test.rb:2: syntax error, unexpected `end', expecting end-of-input
      local pattern = '([^:]+):(%d+): warning: (.+)'
      local severity = severities.Warning

      if line:find(': syntax error,', 1, true) then
        pattern = '([^:]+):(%d+): syntax error, (.+)'
        severity = severities.Error
      end

      local file, lnum, message = line:match(pattern)

      if file and line and message then
        table.insert(items, {
          source = 'ruby',
          range = {
            ['start'] = {
              line = tonumber(lnum) - 1,
              character = 0,
            },
            ['end'] = {
              line = tonumber(lnum) - 1,
              character = 1,
            }
          },
          message = message,
          severity = severity
        })
      end
    end

    return items
  end
})
