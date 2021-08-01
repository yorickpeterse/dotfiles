local M = {}
local error = require('dotfiles.util').error

local workspaces = {
  ['inko'] = '~/Projects/inko/inko',
  ['gitlab'] = '~/Projects/gitlab/gdk-ee/gitlab',
  ['release tools'] = '~/Projects/gitlab/release-tools',
  ['config'] = '~/Projects/general/dotfiles/dotfiles/.config/nvim',
}

local function open(path, title)
  vim.cmd('cd ' .. path)
  vim.go.titlestring = title

  vim.cmd('Tterm')
  vim.cmd('stopinsert')
  vim.cmd('silent file Terminal')
  vim.cmd('tabprev')
end

function M.open(name)
  local path = workspaces[name]

  if path then
    open(path, name)
  else
    error('Invalid workspace name: "' .. name .. '"')
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
