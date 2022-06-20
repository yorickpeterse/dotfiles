local M = {}
local fn = vim.fn
local api = vim.api
local util = require('dotfiles.util')

local function previous_window_id()
  return fn.win_getid(fn.winnr('#'))
end

-- Opens a quickfix or location list item in the previous window, optionally
-- splitting it first.
function M.open_item(split_cmd)
  local prev_win = 0
  local line = fn.line('.')
  local list = fn.getloclist(0, { items = 0, filewinid = 0 })
  local err_cmd = 'cc'

  if list.filewinid > 0 then
    -- The current window is a location list window.
    if #list.items == 0 then
      return
    end

    err_cmd = 'll'
    prev_win = list.filewinid
  else
    if #fn.getqflist() == 0 then
      return
    end

    prev_win = util.target_window(previous_window_id())
  end

  api.nvim_set_current_win(prev_win)

  if split_cmd then
    vim.cmd(split_cmd)
  end

  vim.cmd(err_cmd .. line)
end

function M.closed()
  local closed_win = tonumber(fn.expand('<afile>'))
  local current_win = api.nvim_get_current_win()

  if closed_win == current_win then
    api.nvim_set_current_win(previous_window_id())
  end
end

return M
