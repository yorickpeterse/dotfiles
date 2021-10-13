local M = {}
local util = require('dotfiles.util')
local lint = require('dotfiles.lint')

local fn = vim.fn
local lsp = vim.lsp
local api = vim.api
local diag = vim.diagnostic
local timeout = 100
local timeouts = util.buffer_cache(function() return nil end)
local jumped_var = 'loclist_jumped_after_update'

-- Returns `true` if we should jump to the first item after a location list
-- update.
function first_jump_after_update()
  local win = util.target_window()
  local has_jumped, jumped = pcall(api.nvim_win_get_var, win, jumped_var)

  api.nvim_win_set_var(win, jumped_var, true)

  if has_jumped then
    return not jumped
  else
    return true
  end
end

function same_items(win, new_items)
  local old_items = sort(fn.getloclist(win))

  if #new_items ~= #old_items then
    return false
  end

  for index, new in ipairs(new_items) do
    local old = old_items[index]

    for key, value in pairs(new) do
      if old[key] ~= value then
        return false
      end
    end
  end

  return true
end

function sort(items)
  table.sort(items, function(a, b) return a.lnum < b.lnum end)

  return items
end

function set_location_list(bufnr)
  local items = {}
  local diags = diag.get(bufnr, { severity = { min = diag.severity.WARN } })

  for _, d in ipairs(diags) do
    table.insert(items, {
      bufnr = d.bufnr,
      lnum = d.lnum + 1,
      col = d.col + 1,
      text = d.message,
      type = d.severity == diag.severity.WARN and 'W' or 'E'
    })
  end

  sort(items)

  for _, win in ipairs(fn.getbufinfo(bufnr)[1].windows) do
    -- We only update the location list if the items are different. This ensures
    -- that we don't reset the actively selected item to the first item.
    if not same_items(win, items) then
      api.nvim_win_set_var(win, jumped_var, false)
      fn.setloclist(win, {}, 'r', { title = 'Diagnostics', items = items })
    end
  end
end

local function populate_missing()
  local winid = api.nvim_get_current_win()
  local bufnr = api.nvim_win_get_buf(winid)
  local list = fn.getloclist(winid, { winid = 0, items = 0 })
  local diags = diag.get(bufnr, { severity = { min = diag.severity.WARN } })

  if list and #list.items == #diags then
    return
  end

  local ft = api.nvim_buf_get_option(bufnr, 'ft')

  if util.has_lsp_clients(bufnr) or lint.available(ft) then
    set_location_list(bufnr)
  end
end

function M.toggle()
  populate_missing()

  local winid = api.nvim_get_current_win()
  local list = fn.getloclist(winid, { winid = 0, items = 0 })

  if not list or list.winid == 0 then
    vim.cmd('silent! lopen')
  else
    vim.cmd('silent! lclose')
  end
end

function M.next()
  populate_missing()

  if first_jump_after_update() then
    vim.cmd('try | silent! lfirst | endtry')
  else
    vim.cmd('try | silent lnext | catch | silent! lfirst | endtry')
  end
end

function M.prev()
  populate_missing()
  vim.cmd('try | silent lprev | catch | silent! llast | endtry')
end

-- Populates the location list with diagnostics.
function M.populate(buf, ignore_mode)
  -- If a language server produces diagnostics while typing, updating the
  -- location list can be annoying.
  --
  -- To solve this, we don't update the location list in insert mode by default.
  -- Using an InsertLeave hook we force updating the location list when exiting
  -- insert mode.
  if util.in_insert_mode() and not ignore_mode then
    return
  end

  local bufnr = buf or fn.bufnr()
  local ft = api.nvim_buf_get_option(bufnr, 'ft')

  if not util.has_lsp_clients(bufnr) and not lint.available(ft) then
    return
  end

  if timeouts[bufnr] then
    timeouts[bufnr]:stop()
  end

  local callback = function()
    set_location_list(bufnr)
  end

  timeouts[bufnr] = vim.defer_fn(callback, timeout)
end

return M
