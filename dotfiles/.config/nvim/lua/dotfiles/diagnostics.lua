local M = {}
local util = require('dotfiles.util')
local lsp = vim.lsp
local fn = vim.fn
local diag = vim.diagnostic
local api = vim.api

-- Location information about the last message printed. The format is
-- `(did print, buffer number, line number)`.
local last_echo = { false, -1, -1 }
local echo_timer = nil
local echo_timeout = 250
local warning_hlgroup = 'WarningMsg'
local error_hlgroup = 'ErrorMsg'
local short_line_limit = 20

-- Prints the first diagnostic for the current line.
function M.echo_diagnostic()
  if echo_timer then
    echo_timer:stop()
  end

  echo_timer = vim.defer_fn(
    function()
      local line = fn.line('.') - 1
      local bufnr = api.nvim_win_get_buf(0)

      if last_echo[1] and last_echo[2] == bufnr and last_echo[3] == line then
        return
      end

      local diags =
        diag.get(bufnr, { lnum = line, severity = { min = diag.severity.WARN } })

      if #diags == 0 then
        -- If we previously echo'd a message, clear it out by echoing an empty
        -- message.
        if last_echo[1] then
          last_echo = { false, -1, -1 }

          api.nvim_command('echo ""')
        end

        return
      end

      last_echo = { true, bufnr, line }

      local first = diags[1]
      local width = api.nvim_get_option('columns') - 15
      local lines = vim.split(first.message, "\n")
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

      if first.severity == lsp.protocol.DiagnosticSeverity.Error then
        kind = 'error'
        hlgroup = error_hlgroup
      end

      local chunks = {
        { kind .. ': ', hlgroup },
        { message }
      }

      api.nvim_echo(chunks, false, {})
    end,
    echo_timeout
  )
end

return M
