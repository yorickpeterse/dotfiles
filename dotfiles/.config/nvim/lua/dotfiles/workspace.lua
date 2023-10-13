local M = {}
local error = require('dotfiles.util').error

local workspaces = {
  inko = '~/Projects/inko/inko',
  config = '~/Projects/general/dotfiles/dotfiles/.config/nvim',
  website = '~/Projects/websites/yorickpeterse.com',
}

function M.cd(path)
  vim.cmd.cd(path)
  vim.cmd.Tterm()
  vim.cmd.stopinsert()
  vim.cmd('silent file Terminal')
  vim.cmd.tabprev()
end

function M.open(name)
  local path = workspaces[name]

  if path then
    M.cd(path)
  else
    error(string.format("The workspace '%s' is undefined", name))
  end
end

function M.names(start)
  local names = {}

  for name, _ in pairs(workspaces) do
    if not start or vim.startswith(name, start) then
      table.insert(names, name)
    end
  end

  table.sort(names)

  return names
end

return M
