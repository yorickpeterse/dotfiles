local M = {}
local util = require('dotfiles.util')
local lsp = vim.lsp
local fn = vim.fn
local diag = vim.diagnostic
local api = vim.api
local util = require('dotfiles.util')

-- Location information about the last message printed. The format is
-- `(did print, buffer number, line number)`.
local last_echo = { false, -1, -1 }
local echo_timer = nil
local timeout = 250
local warning_hlgroup = 'WarningMsg'
local error_hlgroup = 'ErrorMsg'
local short_line_limit = 20

local underline_timers = util.buffer_cache(function()
  return 0
end)
local underline_ns = api.nvim_create_namespace('dotfiles_underline')
local underline_hl = {
  [vim.diagnostic.severity.ERROR] = 'DiagnosticUnderlineError',
  [vim.diagnostic.severity.WARN] = 'DiagnosticUnderlineWarn',
  [vim.diagnostic.severity.INFO] = 'DiagnosticUnderlineInfo',
  [vim.diagnostic.severity.HINT] = 'DiagnosticUnderlineHint',
}

local function reset_echo()
  last_echo = { false, -1, -1 }
end

-- Prints the first diagnostic for the current line.
function M.echo_diagnostic()
  if echo_timer then
    echo_timer:stop()
  end

  echo_timer = vim.defer_fn(function()
    local line = fn.line('.') - 1
    local bufnr = api.nvim_win_get_buf(0)

    if last_echo[1] and last_echo[2] == bufnr and last_echo[3] == line then
      return
    end

    local diags = diag.get(
      bufnr,
      { lnum = line, severity = { min = diag.severity.WARN } }
    )

    if #diags == 0 then
      -- If we previously echo'd a message, clear it out by echoing an empty
      -- message.
      if last_echo[1] then
        reset_echo()
        api.nvim_echo({ { '', '' } }, false, {})
      end

      return
    end

    last_echo = { true, bufnr, line }

    local first = diags[1]
    local width = api.nvim_get_option('columns') - 15
    local lines = vim.split(first.message, '\n')
    local message = lines[1]
    local trimmed = false

    if #lines > 1 and #message <= short_line_limit then
      message = message .. ' ' .. lines[2]
    end

    if width > 0 and #message >= width then
      message = message:sub(1, width) .. '...'
    end

    local kind = 'warning'
    local hlgroup = warning_hlgroup

    if first.severity == diag.severity.ERROR then
      kind = 'error'
      hlgroup = error_hlgroup
    end

    local chunks = {
      { kind .. ': ', hlgroup },
      { message },
    }

    api.nvim_echo(chunks, false, {})
  end, timeout)
end

function M.underline()
  local bufnr = api.nvim_win_get_buf(0)
  local timer = underline_timers[bufnr]

  if timer ~= 0 then
    timer:stop()
  end

  underline_timers[bufnr] = vim.defer_fn(function()
    local line = fn.line('.') - 1

    if fn.bufexists(bufnr) == 0 then
      return
    end

    local diags = diag.get(
      bufnr,
      { lnum = line, severity = { min = diag.severity.WARN } }
    )

    api.nvim_buf_clear_namespace(bufnr, underline_ns, 0, -1)

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
      pcall(api.nvim_buf_set_extmark, bufnr, underline_ns, diag.lnum, start_col, {
        end_line = diag.end_lnum,
        end_col = end_col,
        hl_group = underline_hl[diag.severity],
        hl_mode = 'combine',
        virt_text_pos = 'overlay',
      })
    end
  end, timeout)
end

function M.refresh()
  last_echo = { true, -1, -1 }

  M.echo_diagnostic()
  M.underline()
end

return M
