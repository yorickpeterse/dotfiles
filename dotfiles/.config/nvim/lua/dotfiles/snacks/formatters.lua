local snacks = require('snacks')
local format = require('snacks.picker.format')
local M = {}

function M.scoped_symbol(item, picker)
  local opts = picker.opts
  local ret = {}
  local name = vim.trim(item.name:gsub('\r?\n', ' '))

  name = name == '' and item.detail or name
  snacks.picker.highlight.format(item, name, ret)

  local scope = item.parent and item.parent.text

  if scope and scope ~= 'root' then
    local len = 0

    for _, item in ipairs(picker.finder.items) do
      if item.text and #item.text > len then
        len = #item.text
      end
    end

    len = len + 4

    local offset = snacks.picker.highlight.offset(ret, { char_idx = true })

    ret[#ret + 1] = { snacks.picker.util.align(' ', len - offset) }
    ret[#ret + 1] = { item.parent.text, 'Comment' }
  end

  if opts.workspace then
    local offset = snacks.picker.highlight.offset(ret, { char_idx = true })

    ret[#ret + 1] = { snacks.picker.util.align(' ', 40 - offset) }
    vim.list_extend(ret, format.filename(item, picker))
  end

  return ret
end

return M
