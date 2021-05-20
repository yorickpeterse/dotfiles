local pairs = require('nvim-autopairs')
local utils = require('nvim-autopairs.utils')
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


-- This is a gross hack to work around Rust not handling indentation of
-- parentheses properly. Consider this:
--
--     foo(|)
--
--  If you press Enter, the result is this:
--
--      foo(
--          |
--          )
--
--  Using this hack here we can instead turn this into this:
--
--      foo(
--          |
--      )
--
-- When https://github.com/rust-lang/rust.vim/issues/443 is fixed this should be
-- removed.
do
  local orig = utils.esc

  assert(orig, 'nvim-autoairs/utils.esc() is undefined')

  utils.esc = function(keys)
    if keys == '<cr><c-o>O' then
      return orig('<cr><ESC>=ko')
    end

    return orig(keys)
  end
end

return {
  enter = pairs.autopairs_cr
}
