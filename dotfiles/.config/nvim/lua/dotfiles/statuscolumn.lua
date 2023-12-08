local M = {}

function M.render()
  if not vim.o.relativenumber then
    return ' '
  end

  local line = '%s%='

  if vim.v.virtnum == 0 then
    if vim.v.relnum > 0 then
      line = line .. vim.v.relnum
    else
      line = line .. vim.v.lnum
    end
  else
    line = line .. ' '
  end

  return line .. ' '
end

return M
