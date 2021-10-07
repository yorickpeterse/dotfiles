-- Utility functions for my dotfiles.
local api = vim.api
local fn = vim.fn
local lsp = vim.lsp
local M = {}
local diag = vim.diagnostic

-- Returns a callback to use for reading the output of STDOUT or STDERR.
function M.reader(done)
  local output = ''

  return function(err, chunk)
    if chunk then
      output = output .. chunk
    else
      done(output)
    end
  end
end

function M.error(message)
  vim.schedule(function()
    local chunks = {
      { 'error: ', 'ErrorMsg' },
      { message }
    }

    api.nvim_echo(chunks, true, {})
  end)
end

function M.keycode(string)
  return api.nvim_replace_termcodes(string, true, true, true)
end

function M.popup_visible()
  return fn.pumvisible() == 1
end

function M.au(name, commands)
  local cmds = {}

  for _, cmd in ipairs(commands) do
    table.insert(cmds, 'au ' .. cmd)
  end

  local cmd = table.concat({
    'augroup dotfiles_',
    name,
    "\n",
    "autocmd!\n",
    table.concat(cmds, "\n"),
    "\n",
    'augroup END'
  })

  vim.cmd(cmd)
end

function M.has_lsp_clients(buffer)
  return #lsp.buf_get_clients(buffer or api.nvim_get_current_buf()) > 0
end

function M.restore_register(register, func)
  local reg_val = fn.getreg(register)

  func()
  fn.setreg(register, reg_val)
end

function M.set_diagnostics_location_list(bufnr)
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

  table.sort(items, function(a, b) return a.lnum < b.lnum end)

  for _, win in ipairs(fn.getbufinfo(bufnr)[1].windows) do
    fn.setloclist(win, {}, ' ', { title = 'Diagnostics', items = items })
  end
end

return M
