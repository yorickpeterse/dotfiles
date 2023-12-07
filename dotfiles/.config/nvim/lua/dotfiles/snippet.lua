local fn = vim.fn
local api = vim.api
local M = {}

-- The name of the "file type" that defines snippets available to all file
-- types.
local global_key = '_'

-- A flag that indicates if the snippets have been loaded or not.
local loaded = false

-- A table of all snippets per filetype.
local snippets = {
  [global_key] = {},
}

local function remove_text(bufnr, text, line, column)
  local line, col = unpack(api.nvim_win_get_cursor(0))

  api.nvim_buf_set_text(bufnr, line - 1, col - #text, line - 1, col, {})
  api.nvim_win_set_cursor(0, { line, col - #text })
end

local function keyword_at_cursor()
  local line, col = unpack(api.nvim_win_get_cursor(0))
  local line_text = api.nvim_get_current_line()
  local line_to_cursor = line_text:sub(1, col)
  local column = fn.match(line_to_cursor, '\\k*$')

  return line_to_cursor:sub(column + 1)
end

-- Parses a snippets definition using the SnipMate syntax.
local function parse(body)
  local lines = vim.split(body, '\n', { trimempty = true })
  local parsed = {}
  local index = 1

  while index <= #lines do
    local line = lines[index]

    if vim.startswith(line, 'snippet') then
      local name, desc = line:match('snippet (%w+) "([^"]+)"')

      if not name and not desc then
        name = line:match('snippet (%w+)')
      end

      if name then
        local body = {}

        index = index + 1

        while true do
          local line = lines[index]

          if line and (line == '' or vim.startswith(line, '\t')) then
            table.insert(body, lines[index]:sub(2, #lines[index]))
            index = index + 1
          else
            break
          end
        end

        parsed[name] = {
          prefix = name,
          desc = desc,
          body = table.concat(body, '\n'),
        }
      else
        index = index + 1
      end
    else
      index = index + 1
    end
  end

  return parsed
end

local function load()
  if loaded then
    return
  end

  loaded = true

  local dir = fn.stdpath('config') .. '/snippets'

  for name, type in vim.fs.dir(dir) do
    if type == 'file' and vim.endswith(name, '.snippets') then
      local path = dir .. '/' .. name
      local file = io.open(path, 'r')

      if file then
        local data = file:read('*a')

        if data then
          local ft = vim.split(name, '.', { plain = true, trimempty = true })[1]

          snippets[ft] = parse(data)
        end

        file:close()
      end
    end
  end
end

-- Returns the snippets for the given file type.
function M.list(ft)
  load()

  local list = {}
  local sources = { snippets[ft], snippets[global_key] }

  for _, source in ipairs(sources) do
    if source then
      for _, snippet in pairs(source) do
        table.insert(list, snippet)
      end
    end
  end

  return list
end

-- Returns the snippet for the given file type and name.
function M.get(ft, name)
  load()

  local source = snippets[ft]
  local found = nil

  if source then
    found = source[name]
  end

  return found and found or snippets[global_key][name]
end

-- Expands the snippet under the cursor, if there is any.
function M.expand()
  load()

  local buf = api.nvim_get_current_buf()
  local ft = vim.bo[buf].ft
  local name = keyword_at_cursor()
  local snippet = M.get(ft, name)

  if not snippet then
    return
  end

  remove_text(buf, name)
  vim.snippet.expand(snippet.body)
end

-- Formats a snippet body as human readable text
function M.format(body)
  local res = body:gsub('${%d:([^}]+)}', '%1'):gsub('${%d}', ''):gsub('$%d', '')

  return res
end

return M
