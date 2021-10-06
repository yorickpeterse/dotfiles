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
          lnum = tonumber(lnum) - 1,
          end_lnum = tonumber(lnum) - 1,
          col = 0,
          end_col = 1,
          message = message,
          severity = vim.diagnostic.severity.ERROR
        })
      end
    end

    return items
  end
})
