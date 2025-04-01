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

function M.confirm(prompt)
  api.nvim_echo(
    { { prompt .. '?', 'Title' }, { ' (y/N) ', 'Comment' } },
    false,
    {}
  )

  local choice = fn.getchar(-1, { number = false })

  api.nvim_echo({}, false, {})

  return choice == 'y' or choice == 'Y'
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
    if client.supports_method(capability, bufnr) then
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

function M.set_window_option(window, option, value)
  api.nvim_set_option_value(option, value, { win = window, scope = 'local' })
end

function M.set_buffer_lines(buf, namespace, start, stop, chunk_lines)
  local lines = {}

  for _, chunks in ipairs(chunk_lines) do
    local text = {}

    for _, chunk in ipairs(chunks) do
      table.insert(text, chunk[1])
    end

    table.insert(lines, table.concat(text, ''))
  end

  if start > 0 then
    start = start - 1
  end

  if stop > 0 then
    stop = stop - 1
  end

  api.nvim_buf_set_lines(buf, start, stop, true, lines)

  for line, chunks in ipairs(chunk_lines) do
    local offset = 1

    for _, chunk in ipairs(chunks) do
      vim.hl.range(
        buf,
        namespace,
        chunk[2],
        { start + line - 1, offset - 1 },
        { start + line - 1, offset - 1 + #chunk[1] },
        {}
      )

      offset = offset + #chunk[1]
    end
  end
end

function M.format_buffer()
  require('conform').format({
    bufnr = tonumber(fn.expand('<abuf>')),
    timeout_ms = 5000,
    lsp_fallback = true,
    quiet = true,
    filter = function(client)
      return client.name ~= 'sumneko_lua'
    end,
  })
end

return M
