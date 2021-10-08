local pairs = require('nvim-autopairs')
local Rule = require('nvim-autopairs.rule')

pairs.setup()

-- When pressing a space after a pair, insert an extra space before the closing
-- pair.
local space_pairs = { '()', '[]', '{}' }
local pair_rules = {
  Rule(' ', ' '):with_pair(function(opts)
    local pair = opts.line:sub(opts.col - 1, opts.col)

    return vim.tbl_contains(space_pairs, pair)
  end)
}

-- When about to insert a closing pair in a pair separated with a space, jump
-- over the closing pair. So `{ | }` results in `{  }|`.
for _, pair in ipairs(space_pairs) do
  local open = pair:sub(1, 1)
  local close = pair:sub(2, 2)
  local rule = Rule(open .. ' ', ' ' .. close)
    :with_pair(function() return false end)
    :with_move(function(opts)
      return opts.prev_char:match('.%' .. close) ~= nil
    end)
    :use_key(close)

  table.insert(pair_rules, rule)
end

pairs.add_rules(pair_rules)

return {
  enter = pairs.autopairs_cr
}
