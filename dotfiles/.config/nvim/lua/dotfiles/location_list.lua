local M = {}
local util = require('dotfiles.util')
local lint = require('dotfiles.lint')

local fn = vim.fn
local lsp = vim.lsp
local api = vim.api
local diag = vim.diagnostic
local timeout = 100
local timeouts = {}

function M.populate_sync(buf)
  local bufnr = buf or fn.bufnr()
  local ft = api.nvim_buf_get_option(bufnr, 'ft')

  if not util.has_lsp_clients(bufnr) and not lint.available(ft) then
    return
  end

  util.set_diagnostics_location_list(bufnr)
end

-- Populates the location list with diagnostics.
function M.populate(buf)
  local bufnr = buf or fn.bufnr()
  local ft = api.nvim_buf_get_option(bufnr, 'ft')

  if not util.has_lsp_clients(bufnr) and not lint.available(ft) then
    return
  end

  if timeouts[bufnr] then
    timeouts[bufnr]:stop()
  else
    -- Clear the cache when the buffer unloads
    api.nvim_buf_attach(bufnr, false, {
      on_detach = function()
        timeouts[bufnr] = nil
      end
    })
  end

  local callback = function()
    util.set_diagnostics_location_list(bufnr)
  end

  timeouts[bufnr] = vim.defer_fn(callback, timeout)
end

return M
