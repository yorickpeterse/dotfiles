-- Utility functions for my dotfiles.
local api = vim.api
local fn = vim.fn
local lsp = vim.lsp
local M = {}

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

function M.pad_right(string, pad_to)
  local new = string

  for i = #string, pad_to do
    new = new .. ' '
  end

  return new
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

return M
