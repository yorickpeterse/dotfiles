local M = {}
local util = require('dotfiles.util')

local fn = vim.fn
local api = vim.api
local diag = vim.diagnostic
local timeout = 100
local updates = util.buffer_cache(function()
  return 0
end)
local jumped_var = 'loclist_jumped_after_update'
local last_update_var = 'last_diagnostics_update'
local changed_timer = nil

local function first_jump_after_update()
  local win = util.target_window()
  local has_jumped, jumped = pcall(api.nvim_win_get_var, win, jumped_var)

  api.nvim_win_set_var(win, jumped_var, true)

  if has_jumped then
    return not jumped
  else
    return true
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

  for _, d in ipairs(diags) do
    table.insert(items, {
      bufnr = d.bufnr,
      lnum = d.lnum + 1,
      col = d.col + 1,
      text = d.message,
      type = d.severity == diag.severity.WARN and 'W' or 'E',
    })
  end

  table.sort(items, function(a, b)
    return a.lnum < b.lnum
  end)

  api.nvim_win_set_var(win, last_update_var, updates[bufnr])
  api.nvim_win_set_var(win, jumped_var, false)

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

-- Jumps to the first or next item in the location list.
--
-- If the diagnostics have been updated and we haven't jumped yet, we jump to
-- the first selected entry; instead of the second one. If we jumped before, we
-- just jump to the next one.
function M.next()
  if first_jump_after_update() then
    pcall(api.nvim_exec, 'lfirst', true)
  elseif not pcall(api.nvim_exec, 'lnext', true) then
    pcall(api.nvim_exec, 'lfirst', true)
  end
end

-- Jumps to the previous item in the location list.
function M.prev()
  if first_jump_after_update() then
    pcall(api.nvim_exec, 'llast', true)
  elseif not pcall(api.nvim_exec, 'lprev', true) then
    pcall(api.nvim_exec, 'llast', true)
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
