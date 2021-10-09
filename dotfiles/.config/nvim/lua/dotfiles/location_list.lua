local M = {}
local util = require('dotfiles.util')
local lint = require('dotfiles.lint')

local fn = vim.fn
local lsp = vim.lsp
local api = vim.api
local diag = vim.diagnostic
local timeout = 100
local timeouts = util.buffer_cache(function() return nil end)

function M.populate_sync(buf)
  local bufnr = buf or fn.bufnr()
  local ft = api.nvim_buf_get_option(bufnr, 'ft')

  if not util.has_lsp_clients(bufnr) and not lint.available(ft) then
    return
  end

  util.set_diagnostics_location_list(bufnr)
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
    util.set_diagnostics_location_list(bufnr)
  end

  timeouts[bufnr] = vim.defer_fn(callback, timeout)
end

return M
