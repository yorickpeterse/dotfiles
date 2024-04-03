local M = {}
local fn = vim.fn
local diag = vim.diagnostic
local api = vim.api
local util = require('dotfiles.util')

local TIMEOUT = 250
local TIMERS = util.buffer_cache(function()
  return 0
end)
local NAMESPACE = api.nvim_create_namespace('dotfiles_underline')
local HIGHLIGHTS = {
  [vim.diagnostic.severity.ERROR] = 'DiagnosticUnderlineError',
  [vim.diagnostic.severity.WARN] = 'DiagnosticUnderlineWarn',
  [vim.diagnostic.severity.INFO] = 'DiagnosticUnderlineInfo',
  [vim.diagnostic.severity.HINT] = 'DiagnosticUnderlineHint',
}

function M.underline()
  local bufnr = api.nvim_win_get_buf(0)
  local timer = TIMERS[bufnr]

  if timer ~= 0 then
    timer:stop()
  end

  TIMERS[bufnr] = vim.defer_fn(function()
    local line = fn.line('.') - 1

    if fn.bufexists(bufnr) == 0 then
      return
    end

    local diags =
      diag.get(bufnr, { lnum = line, severity = { min = diag.severity.WARN } })

    api.nvim_buf_clear_namespace(bufnr, NAMESPACE, 0, -1)

    for _, diag in ipairs(diags) do
      local start_col = diag.col
      local end_col = diag.end_col

      -- Some servers may use the same start/end column when producing syntax
      -- errors. Since end columns are exclusive, we need to increment them so
      -- they are highlighted.
      if start_col == end_col then
        end_col = end_col + 1
      end

      -- In case the start/end column is out of range, we just ignore the
      -- diagnostic.
      pcall(api.nvim_buf_set_extmark, bufnr, NAMESPACE, diag.lnum, start_col, {
        end_line = diag.end_lnum,
        end_col = end_col,
        hl_group = HIGHLIGHTS[diag.severity],
        hl_mode = 'combine',
        virt_text_pos = 'overlay',
      })
    end
  end, TIMEOUT)
end

function M.refresh()
  M.underline()
end

return M
