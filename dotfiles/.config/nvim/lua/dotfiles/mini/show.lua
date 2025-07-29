local pick = require('mini.pick')
local icons = require('mini.icons')
local api = vim.api

local M = {}
local NS = api.nvim_create_namespace('dotfiles_mini_show')

function M.scoped_symbols(buf, items, query, opts)
  api.nvim_buf_clear_namespace(buf, NS, 0, -1)

  -- Injecting the icon at the start of the line results in the cursor line
  -- highlight being shifted to the right, instead of it going "under" the icon.
  -- To work around that we inject two spaces (one for the icon and one for the
  -- space after it) to each line. We have to use deepcopy() here so we don't
  -- modify the data in-place and add more spaces every time the list is
  -- filtered.
  local items = vim.deepcopy(items)

  for _, item in ipairs(items) do
    item.text = '  ' .. item.text
  end

  local ret = pick.default_show(buf, items, query, opts)
  local max = 0

  for _, item in ipairs(items) do
    if #item.text > max then
      max = #item.text
    end
  end

  for idx, item in ipairs(items) do
    local line = idx - 1

    if item.kind then
      local icon, icon_hl = icons.get('lsp', item.kind)

      if icon then
        api.nvim_buf_set_extmark(buf, NS, line, 0, {
          virt_text = { { icon, icon_hl } },
          virt_text_pos = 'overlay',
          hl_mode = 'combine',
        })
      end
    end

    if item.parent.text then
      local col = #item.text
      local pad = max - #item.text
      local scope = string.rep(' ', pad + 4) .. item.parent.text

      api.nvim_buf_set_extmark(buf, NS, line, col, {
        virt_text = { { scope, 'Comment' } },
        virt_text_pos = 'inline',
        hl_mode = 'combine',
      })
    end
  end

  return ret
end

return M
