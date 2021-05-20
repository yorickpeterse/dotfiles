local lint = require('dotfiles.lint')
local util = require('dotfiles.lint.util')

local config_file = '.gitlint'

lint.linter('gitcommit', {
  name = 'gitlint',
  exe = function(path)
    local config = util.find_file(config_file)
    local args = { '--msg-filename', path }

    if config ~= '' then
      table.insert(args, '--config')
      table.insert(args, config)
    end

    table.insert(args, 'lint')

    return 'gitlint', args
  end,
  enable = function()
    return util.find_file(config_file) ~= ''
  end,
  stream = 'stderr',
  ignore_exitcode = true,
  parse = function(output)
    local items = {}

    for line in vim.gsplit(output, '\n') do
      local line, message = line:match('(%d+): %w+ ([^:]+)')

      if line and message then
        table.insert(items, {
          source = 'gitlint',
          range = {
            ['start'] = {
              line = tonumber(line) - 1,
              character = 0
            },
            ['end'] = {
              line = tonumber(line) - 1,
              character = 0
            }
          },
          message = message,
          severity = vim.lsp.protocol.DiagnosticSeverity.Error,
        })
      end
    end

    return items
  end
})
