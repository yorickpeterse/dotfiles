-- Utility functions for my dotfiles.
local api = vim.api
local fn = vim.fn
local lsp = vim.lsp
local M = {}

-- This is the "EN SPACE" character. Regular and unbreakable spaces sometimes
-- get swallowed in statuslines. This kind of space doesn't.
-- local forced_space = utf8.char(8194)
M.forced_space = string.char(226, 128, 130)

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

function M.in_insert_mode()
  return api.nvim_get_mode().mode == 'i'
end

function M.buffer_cache(default)
  local cache = {}
  local mt = {
    __index = function(table, buffer)
      local val = default()
      table[buffer] = val

      api.nvim_buf_attach(buffer, false, {
        on_detach = function()
          table[buffer] = nil
        end
      })

      return val
    end
  }

  setmetatable(cache, mt)

  return cache
end

-- Returns the ID of the current window, or the ID of the target window if the
-- current window is a location list window.
function M.target_window()
  local win = api.nvim_get_current_win()
  local list = fn.getloclist(win, { filewinid = 0 })

  if list.filewinid > 0 then
    win = list.filewinid
  end

  return win
end

function M.statusline_highlight(text, group)
  return '%#' .. group .. '#' .. text .. '%*'
end

return M
