local fn = vim.fn
local M = {}

-- A findfunc implementation that uses fd (https://github.com/sharkdp/fd) to do
-- the heavy lifting.
--
-- Using fd instead of `rg --files` means we don't need to load a (potentially)
-- large list of files into Lua and then filter it.
function M.find(arg, cmd)
  -- fd doesn't return anything when given a path that exists.
  if vim.uv.fs_stat(arg) then
    return { arg }
  end

  local query = arg:gsub('%s', '.*')
  local res = vim
    .system({ 'fd', '--hidden', '--exclude=.git', query }, { text = true })
    :wait()

  local lines = vim.split(res.stdout, '\n', { trimempty = true })

  -- The output is not in a deterministic order, so we sort the lines
  -- alphabetically in ascending order.
  table.sort(lines, function(a, b)
    return a < b
  end)

  return lines
end

return M
