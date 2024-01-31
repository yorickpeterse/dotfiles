-- Restores window cursor/scroll positions when moving between buffers in the
-- same window.
local M = {}
local api = vim.api
local fn = vim.fn
local state = {}

local function same_states(a, b)
  for k, v in pairs(a) do
    if b[k] ~= v then
      return false
    end
  end

  return true
end

function M.save()
  local win = api.nvim_get_current_win()
  local buf = api.nvim_win_get_buf(win)

  if not state[win] then
    state[win] = {}
  end

  state[win][buf] = fn.winsaveview()
end

function M.restore()
  local win = api.nvim_get_current_win()
  local buf = api.nvim_win_get_buf(win)
  local old = state[win] and state[win][buf]

  if not old then
    return
  end

  local new = fn.winsaveview()

  if new.lnum == 1 and new.col == 0 and not same_states(old, new) then
    fn.winrestview(old)
  end

  state[win][buf] = nil
end

function M.wipe_buffer(info)
  for win, bufs in pairs(state) do
    bufs[info.buf] = nil
  end
end

function M.close_window(info)
  state[api.nvim_get_current_win()] = nil
end

return M
