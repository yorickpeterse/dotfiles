local M = {}
local error = require('dotfiles.util').error

local workspaces = {
  ['inko'] = {
    path = '~/Projects/inko/inko',
    terminal = true,
  },
  ['config'] = {
    path = '~/Projects/general/dotfiles/dotfiles/.config/nvim',
    terminal = true,
  },
}

local function open(title, workspace)
  vim.cmd('cd ' .. workspace.path)
  vim.go.titlestring = title

  if workspace.terminal then
    vim.cmd('Tterm')
    vim.cmd('stopinsert')
    vim.cmd('silent file Terminal')
    vim.cmd('tabprev')
  end
end

function M.open(name)
  local workspace = workspaces[name]

  if workspace then
    open(name, workspace)
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
