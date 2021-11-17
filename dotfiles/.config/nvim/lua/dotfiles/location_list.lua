local M = {}
local util = require('dotfiles.util')

local fn = vim.fn
local api = vim.api
local diag = vim.diagnostic
local timeout = 100
local updates = util.buffer_cache(function()
  return 0
end)
local last_update_var = 'last_diagnostics_update'
local changed_timer = nil

local signs = {
  [diag.severity.ERROR] = 'E',
  [diag.severity.WARN] = 'W',
  [diag.severity.INFO] = 'I',
  [diag.severity.HINT] = 'H',
}

local function line_length(bufnr, lnum)
  return #api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
end

local function switch_to_target_window(target)
  if api.nvim_get_current_win() ~= target then
    api.nvim_set_current_win(target)
  end
end

local function update_window(win, diags)
  local bufnr = api.nvim_win_get_buf(win)
  local items = {}
  local last_exists, last_value = pcall(
    api.nvim_win_get_var,
    win,
    last_update_var
  )

  -- If the diagnostics haven't changed since the last update, leave the
  -- location list as-is.
  if last_exists and last_value == updates[bufnr] then
    return
  end

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

  api.nvim_win_set_var(win, last_update_var, updates[bufnr])

  fn.setloclist(win, {}, ' ', { title = 'Diagnostics', items = items })
end

local function buffer_windows(bufnr)
  local info = fn.getbufinfo(bufnr)[1]

  return info and info.windows or {}
end

-- Updates the location lists of all windows that have a buffer with
-- diagnostics.
local function update_all()
  local all_diags = diag.get(nil, { severity = { min = diag.severity.WARN } })
  local per_buffer = {}

  for _, diag in ipairs(all_diags) do
    if not per_buffer[diag.bufnr] then
      per_buffer[diag.bufnr] = {}
    end

    table.insert(per_buffer[diag.bufnr], diag)
  end

  for bufnr, _ in pairs(updates) do
    for _, window in ipairs(buffer_windows(bufnr)) do
      update_window(window, per_buffer[bufnr] or {})
    end
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
  if changed_timer then
    changed_timer:stop()
  end

  changed_timer = vim.defer_fn(update_all, timeout)
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
    api.nvim_exec('lfirst', true)
  elseif not pcall(api.nvim_exec, 'lafter', true) then
    -- When the last item is selected, but the cursor is beyond it, `lafter`
    -- will error. But if the cursor is on the same position, it won't.
    api.nvim_exec('lfirst', true)
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

  if not pcall(api.nvim_exec, 'lbefore', true) then
    api.nvim_exec('llast', true)
  end
end

-- To prevent updating location lists with the same data, we keep track of what
-- buffers are updated. This way if a buffer isn't updated we don't mess with
-- its location list(s) and the actively selected items.
--
-- To support _any_ API that may produce diagnostics and not just language
-- server clients, we override `vim.diagnostic.set`.
--
-- TODO: remove once https://github.com/neovim/neovim/pull/16098 is merged
do
  local old = diag.set

  diag.set = function(namespace, bufnr, diagnostics, opts)
    old(namespace, bufnr, diagnostics, opts)

    updates[bufnr] = updates[bufnr] + 1
  end
end

return M
