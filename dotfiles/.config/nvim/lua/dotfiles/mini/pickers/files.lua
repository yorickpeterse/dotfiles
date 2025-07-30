local pick = require('mini.pick')
local M = {}

function M.start()
  pick.builtin.cli({
    command = {
      'fd',
      '--type=f',
      '--no-follow',
      '--color=never',
      '--hidden',
      '--exclude=.git',
    },
  }, {
    source = {
      name = 'Files',
      show = function(buf, items, query, opts)
        pick.default_show(buf, items, query, { show_icons = true })
      end,
    },
  })
end

return M
