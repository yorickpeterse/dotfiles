local pairs = require('nvim-autopairs')
local Rule = require('nvim-autopairs.rule')

pairs.setup()

-- Disable matching of single quotes in Rust.
pairs.get_rule("'"):with_pair(function()
  if vim.bo.filetype == 'rust' then
    return false
  end

  return true
end)

-- When pressing a space after a pair, insert an extra space before the closing
-- pair.
local space_pairs = { '()', '[]', '{}' }

pairs.add_rules({
  Rule(' ', ' '):with_pair(function(opts)
    local pair = opts.line:sub(opts.col, opts.col + 1)

    return vim.tbl_contains(space_pairs, pair)
  end),
})

return {
  enter = pairs.autopairs_cr
}
