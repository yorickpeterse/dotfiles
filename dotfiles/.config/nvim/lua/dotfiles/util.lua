-- Utility functions for my dotfiles.
local api = vim.api
local fn = vim.fn
local lsp = vim.lsp
local uv = vim.loop
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
      { message },
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

function M.has_lsp_clients(buffer)
  return #lsp.buf_get_clients(buffer or api.nvim_get_current_buf()) > 0
end

function M.restore_register(register, func)
  local reg_val = fn.getreg(register)

  func()
  fn.setreg(register, reg_val)
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
        end,
      })

      return val
    end,
  }

  setmetatable(cache, mt)

  return cache
end

-- Returns the ID of the current window, or the ID of the target window if the
-- current window is a location list window.
function M.target_window(win)
  win = win or api.nvim_get_current_win()

  local list = fn.getloclist(win, { filewinid = 0 })

  if list.filewinid > 0 then
    win = list.filewinid
  end

  return win
end

function M.statusline_highlight(text, group)
  return '%#' .. group .. '#' .. text .. '%*'
end

function M.read(path, remove_trailing_newline)
  local file = assert(io.open(path, 'r'), 'Failed to open ' .. path)
  local data = file:read('*all')

  file:close()

  if remove_trailing_newline and data:sub(#data, #data) == '\n' then
    data = data:sub(1, #data - 1)
  end

  return data
end

function M.cached(table, key, func)
  if table[key] == nil then
    table[key] = func()
  end

  return table[key]
end

function M.file_exists(path)
  local stat = vim.loop.fs_stat(path)
  local kind = stat and stat.type

  return kind == 'file'
end

function M.path_relative_to_lsp_root(client_id, path)
  local client = lsp.get_client_by_id(client_id)
  local root = client.config.root_dir or uv.cwd()

  return table.concat({ root, path }, '/')
end

-- Returns an integer indicating if Bundler should be used for the given Gem.
--
-- This function returns one of the following integers:
--
-- - 0: don't use the Gem at all
-- - 1: run the Gem without bundler
-- - 2: run the Gem with bundler
function M.use_bundler(gem, lockfile)
  if not M.file_exists(lockfile) then
    return 1
  end

  if M.read(lockfile, true):match(' ' .. gem .. ' ') ~= nil then
    return 2
  end

  return 0
end

function M.has_lsp_clients_supporting(bufnr, capability)
  local supported = false

  for _, client in pairs(lsp.buf_get_clients(bufnr)) do
    if client.supports_method(capability) then
      supported = true
      break
    end
  end

  return supported
end

function M.scroll_if_near_edge()
  local lnum = fn.getpos('.')[2]
  local first_line = fn.line('w0')
  local last_line = fn.line('w$')
  local command = nil

  if lnum == first_line then
    command = '<C-y>'
  elseif lnum == last_line then
    command = '<C-e>'
  else
    return
  end

  -- This manually unrolled loop is webscale
  api.nvim_feedkeys(M.keycode(command), 'n', true)
  api.nvim_feedkeys(M.keycode(command), 'n', true)
  api.nvim_feedkeys(M.keycode(command), 'n', true)
end

return M
