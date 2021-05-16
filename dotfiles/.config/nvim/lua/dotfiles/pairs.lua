local pears = require('pears')
local R = require('pears/rule')

local not_after_alpha = R.not_(R.start_of_context('[a-zA-Z]'))

pears.setup(function(conf)
  conf.pair('{ ', { close = ' }' })
  conf.pair('[ ', { close = ' ]' })
  conf.pair('( ', { close = ' )' })

  conf.pair("'", {
    should_expand = function(rule)
      -- Rust uses single quotes for both lifetimes and characters. As
      -- characters are used less often compared to lifetimes, we disable
      -- single quote expansion for Rust.
      if rule.lang == 'rust' then
        return false
      end

      return not_after_alpha(rule)
    end,
  })

  conf.pair('"', { should_expand = not_after_alpha })
end)
