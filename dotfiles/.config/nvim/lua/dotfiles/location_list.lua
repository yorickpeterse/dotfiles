local M = {}
local util = require('dotfiles.util')

local fn = vim.fn
local api = vim.api
local diag = vim.diagnostic
local timeout = 100
local timers = util.buffer_cache(function()
  return false
end)

local signs = {
  [diag.severity.ERROR] = 'E',
  [diag.severity.WARN] = 'W',
  [diag.severity.INFO] = 'I',
  [diag.severity.HINT] = 'H',
}

local function line_length(bufnr, lnum)
  local line = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]

  return line and #line or 0
end

local function switch_to_target_window(target)
  if api.nvim_get_current_win() ~= target then
    api.nvim_set_current_win(target)
  end
end

local function update_window(win, diags)
  local bufnr = api.nvim_win_get_buf(win)
  local items = {}
  local line_lengths = {}

  for _, d in ipairs(diags) do
    local bufnr = d.bufnr
    local lnum = d.lnum + 1
    local col = d.col + 1

    if not line_lengths[bufnr] then
      line_lengths[bufnr] = {}
    end

    if not line_lengths[bufnr][lnum] then
      line_lengths[bufnr][lnum] = line_length(bufnr, lnum)
    end

    -- Diagnostics may use column numbers that are out of bound. This usually
    -- happens when a language server produces syntax errors, without clamping
    -- the column numbers to the maximum column. This then messes up commands
    -- such as `lafter`, as they won't be able to jump past an out-of-bounds
    -- entry.
    col = math.min(col, line_lengths[bufnr][lnum])

    table.insert(items, {
      bufnr = bufnr,
      lnum = lnum,
      col = col,
      text = d.message,
      type = signs[d.severity] or 'E',
    })
  end

  table.sort(items, function(a, b)
    if a.lnum == b.lnum then
      return a.col < b.col
    else
      return a.lnum < b.lnum
    end
  end)

  fn.setloclist(win, {}, ' ', { title = 'Diagnostics', items = items })
end

local function buffer_windows(bufnr)
  local info = fn.getbufinfo(bufnr)[1]

  return info and info.windows or {}
end

-- Updates the location lists of all windows to the given buffer
local function update_all(bufnr)
  if fn.bufexists(bufnr) == 0 then
    return
  end

  local diags = diag.get(bufnr, { severity = { min = diag.severity.WARN } })

  for _, window in ipairs(buffer_windows(bufnr)) do
    update_window(window, diags)
  end
end

-- Updates the location list when entering a window for the first time (e.g.
-- after the buffer was hidden).
function M.enter_window()
  if vim.bo.buftype ~= '' then
    -- We only care about regular windows, and not about windows such as
    -- quickfix and help windows.
    return
  end

  local win = util.target_window()
  local bufnr = api.nvim_win_get_buf(win)

  -- If a buffer never produces diagnostics there's no point in updating the
  -- location list.
  if not util.has_lsp_clients(bufnr) then
    return
  end

  local diags = diag.get(bufnr, { severity = { min = diag.severity.WARN } })

  update_window(win, diags)
end

-- Updates all windows when the diagnostics change.
--
-- This function may be called often, so we use a timer to coalesce many calls
-- into a single update.
function M.diagnostics_changed()
  local bufnr = fn.bufnr(fn.expand('<afile>'))

  if timers[bufnr] then
    timers[bufnr]:stop()
  end

  timers[bufnr] = vim.defer_fn(function()
    update_all(bufnr)

    -- Needed to ensure the diagnostics in the statusline are updated.
    vim.cmd.redrawstatus()
  end, timeout)
end

-- Toggles the location list.
function M.toggle()
  local winid = api.nvim_get_current_win()
  local list = fn.getloclist(winid, { winid = 0 })

  if not list or list.winid == 0 then
    pcall(api.nvim_command, 'lopen')
  else
    pcall(api.nvim_command, 'lclose')
  end
end

-- Jumps to the next location list item closest to the cursor.
function M.next()
  local target = util.target_window()
  local list = fn.getloclist(target, { idx = 0, size = 1 })

  if list.size == 0 then
    return
  end

  switch_to_target_window(target)

  if list.idx == list.size then
    api.nvim_exec2('lfirst', { output = true })
  elseif not pcall(api.nvim_exec2, 'lafter', { output = true }) then
    -- When the last item is selected, but the cursor is beyond it, `lafter`
    -- will error. But if the cursor is on the same position, it won't.
    api.nvim_exec2('lfirst', { output = true })
  end
end

-- Jumps to the previous location list item closest to the cursor.
function M.prev()
  local target = util.target_window()
  local list = fn.getloclist(target, { size = 1 })

  if list.size == 0 then
    return
  end

  switch_to_target_window(target)

  if not pcall(api.nvim_exec2, 'lbefore', { output = true }) then
    api.nvim_exec2('llast', { output = true })
  end
end

return M
