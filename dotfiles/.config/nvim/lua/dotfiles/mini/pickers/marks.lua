local pick = require('mini.pick')
local fn = vim.fn
local api = vim.api
local M = {}
local NS = api.nvim_create_namespace('dotfiles_mini_marks')

local function show(buf, items, query, opts)
  api.nvim_buf_clear_namespace(buf, NS, 0, -1)

  local items = vim.deepcopy(items)

  for _, item in ipairs(items) do
    local loc = item.location
    local pad = #loc.name + 1 + #loc.file + 1 + #loc.line

    item.text = string.rep(' ', pad) .. ' ' .. item.text
  end

  local ret = pick.default_show(buf, items, query, opts)

  for idx, item in ipairs(items) do
    local line = idx - 1

    api.nvim_buf_set_extmark(buf, NS, line, 0, {
      virt_text = {
        { item.location.name, 'Title' },
        { ' ', '' },
        { item.location.file, 'Directory' },
        { ':', 'Comment' },
        { item.location.line, 'Number' },
      },
      virt_text_pos = 'overlay',
      hl_mode = 'combine',
    })
  end

  return ret
end

function M.start()
  local items = {}
  local buf = api.nvim_get_current_buf()
  local marks = fn.getmarklist(buf)

  for _, mark in ipairs(fn.getmarklist()) do
    table.insert(marks, mark)
  end

  table.sort(marks, function(a, b)
    return a.mark < b.mark
  end)

  for _, mark in ipairs(marks) do
    if mark.mark:match("'%a") then
      local buf = mark.pos[1]
      local lnum = mark.pos[2]
      local col = mark.pos[3]
      local line =
        api.nvim_buf_get_lines(buf, lnum - 1, lnum, true)[1]:sub(col, col + 60)

      local loc = fn.fnamemodify(api.nvim_buf_get_name(buf), ':t')
      local name = mark.mark:sub(2)

      table.insert(items, {
        mark = name,
        text = vim.trim(line),
        location = {
          name = name,
          file = loc,
          line = tostring(lnum),
        },
        buf = buf,
        lnum = lnum,
        col = col,
      })
    end
  end

  pick.start({
    source = {
      items = items,
      name = 'Named marks',
      show = show,
    },
  })
end

return M
