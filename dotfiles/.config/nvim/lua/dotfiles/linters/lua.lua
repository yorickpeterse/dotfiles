local lint = require('dotfiles.lint')

lint.linter('lua', {
  name = 'lua',
  exe = function(path)
    return 'luac', { '-p', path }
  end,
  stream = 'stderr',
  parse = function(output)
    local items = {}

    for line in vim.gsplit(output, '\n') do
      local lnum, message = line:match('luac: [^:]+:(%d+): (.+)')

      if lnum and message then
        table.insert(items, {
          source = 'lua',
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
          severity = vim.lsp.protocol.DiagnosticSeverity.Error
        })
      end
    end

    return items
  end
})
