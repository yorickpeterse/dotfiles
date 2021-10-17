local mpairs = require('mini.pairs')
local M = {}
local newline_pairs = { '()', '[]', '{}' }

mpairs.setup()

function M.enter()
  return mpairs.cr(newline_pairs)
end

function M.single_quote()
  if vim.bo.ft == 'rust' then
    -- Rust uses single quotes for lifetimes. Having to delete the closing quote
    -- is too annoying, so pairing single quotes is disabled.
    return "'"
  else
    return mpairs.closeopen("''", '[^%a\\].')
  end
end

return M
