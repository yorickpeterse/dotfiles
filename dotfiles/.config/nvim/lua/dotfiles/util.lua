-- Utility functions for my dotfiles.
local api = vim.api
local fn = vim.fn
local lsp = vim.lsp
local M = {}

function M.error(message)
  vim.schedule(function()
    local chunks = {
      { 'error: ', 'ErrorMsg' },
      { message },
    }

    api.nvim_echo(chunks, true, {})
  end)
end

function M.popup_visible()
  return fn.pumvisible() == 1
end

function M.has_lsp_clients(buffer)
  return #lsp.get_clients({ bufnr = buffer or api.nvim_get_current_buf() }) > 0
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

function M.file_exists(path)
  local stat = vim.uv.fs_stat(path)
  local kind = stat and stat.type

  return kind == 'file'
end

function M.has_lsp_clients_supporting(bufnr, capability)
  local supported = false

  for _, client in pairs(lsp.get_clients({ bufnr = bufnr })) do
    if client.supports_method(capability) then
      supported = true
      break
    end
  end

  return supported
end

function M.find_directory(name, relative_to)
  local path = fn.finddir(name, fn.fnamemodify(relative_to, ':h') .. ';')

  return fn.fnamemodify(path, ':p')
end

return M
