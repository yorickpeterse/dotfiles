local M = {}
local fn = vim.fn
local lsp = vim.lsp
local api = vim.api

local function buffer_cache()
  local cache = {}
  local mt = {
    __index = function(table, buffer)
      table[buffer] = {}

      api.nvim_buf_attach(buffer, false, {
        on_detach = function()
          table[buffer] = nil
        end
      })

      return table[buffer]
    end
  }

  setmetatable(cache, mt)

  return cache
end

local original_on_publish = lsp.diagnostic.on_publish_diagnostics

-- Diagnostics that were produced while in insert mode.
local cached = buffer_cache()

-- Diagnostics produced while not in insert mode. These will be published
-- automatically after a short period of time.
local pending = buffer_cache()

local config = {
  -- The time (in milliseconds) after which diagnostics should be produced.
  timeout = 1000
}

local function schedule(result, ctx, cfg)
  return vim.defer_fn(
    function() original_on_publish(nil, result, ctx, cfg) end,
    config.timeout
  )
end

-- The various modes that for which we don't want diagnostics to show while we
-- are in those modes.
local ignore_modes = { i = true, ic = true, ix = true }

function M.defer(result, ctx, config)
  local client = ctx.client_id
  local uri = result.uri
  local buffer = vim.uri_to_bufnr(uri)

  if pending[buffer][client] then
    pending[buffer][client]:stop()
  end

  -- In insert mode we don't want the diagnostics to show up, even if we wait a
  -- long time after we stop typing.
  --
  -- When displaying the popup menu, (Neo)Vim enters normal mode, even though it
  -- appears as if (Neo)Vim is in insert mode. In this case we also don't want
  -- diagnostics to show up just yet.
  local mode = api.nvim_get_mode().mode

  if fn.pumvisible() == 1 or ignore_modes[mode] then
    cached[buffer][client] = { result = result, ctx = ctx, config = config }
    return
  end

  pending[buffer][client] = schedule(result, ctx, config)
end

function M.flush()
  local buffer = fn.bufnr(fn.expand('<afile>'))

  for _, data in pairs(cached[buffer]) do
    pending[buffer][data.ctx.client_id] =
      schedule(data.result, data.ctx, data.config)
  end

  cached[buffer] = {}
end

function M.setup(options)
  if options then
    config = vim.tbl_extend('force', config, options)
  end

  if not lsp.diagnostic.on_publish_diagnostics then
    error('vim.lsp.diagnostic.on_publish_diagnostics is undefined.')
  end

  vim.cmd([[
    augroup defer_diagnostics
      autocmd!
      au InsertLeave * lua require('dotfiles.defer_diagnostics').flush()
    augroup END
  ]])

  lsp.diagnostic.on_publish_diagnostics = function(_, result, ctx, config)
    M.defer(result, ctx, config)
  end
end

return M
