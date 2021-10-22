local M = {}

-- Decodes JSON and handles empty input/output.
function M.json_decode(input)
  if input == '' then
    return {}
  else
    local output = vim.json.decode(input, { luanil = { object = true } })

    if output == nil then
      return {}
    else
      return output
    end
  end
end

-- Returns the path leading up to (and including) the given directory, based on
-- the current buffer's file path.
--
-- Example:
--
-- The buffer path is `foo/bar/baz.txt`. When calling this function with the
-- first argument set to `bar`, this function returns `foo/bar`.
function M.find_nearest_directory(directory)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p')
  local filename = vim.fn.fnameescape(filename)
  local relative_path = vim.fn.finddir(directory, filename .. ';')

  if relative_path == '' then
    return ''
  end

  return vim.fn.fnamemodify(relative_path, ':p')
end

-- Returns the full path to the current buffer.
function M.buffer_path()
  return vim.fn.expand('%:p')
end

-- Returns the full path to the buffer's directory.
function M.buffer_directory()
  return vim.fn.expand('%:p:h')
end

-- Finds and returns the path of a given file, if it could be found.
function M.find_file(name)
  local relative = vim.fn.findfile(name, M.buffer_directory() .. ';')

  if relative == '' then
    return ''
  end

  return vim.fn.fnamemodify(relative, ':p')
end

return M
