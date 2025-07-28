local fn = vim.fn
local M = {}

function M.find(arg, cmd)
  local lines = fn.systemlist('rg --hidden --files --glob=!.git/\\*')
  local query = vim.split(vim.pesc(arg:lower()), '%s', { trimempty = true })
  local matches = {}

  for _, line in ipairs(lines) do
    local search = line:lower()
    local match = true
    local len = 0

    for _, pat in ipairs(query) do
      local start, stop = search:find(pat)

      if not start then
        match = false
        break
      end

      len = len + (stop - start)
    end

    if match then
      table.insert(matches, { text = line, score = len / #line })
    end
  end

  table.sort(matches, function(a, b)
    return (a.score == b.score) and (a.text < b.text) or (a.score > b.score)
  end)

  return vim.tbl_map(function(i)
    return i.text
  end, matches)
end

return M
