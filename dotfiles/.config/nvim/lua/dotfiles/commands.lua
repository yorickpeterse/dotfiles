local package = require('dotfiles.package')
local workspace = require('dotfiles.workspace')
local M = {}

local function cmd(name, func, opts)
  vim.api.nvim_create_user_command(name, func, opts or {})
end

local function terminal(cmd)
  vim.cmd(cmd)
  vim.wo.scrolloff = 0
  vim.cmd('term')
  vim.cmd('startinsert')
end

cmd('Term', function()
  terminal('new')
end)

cmd('Vterm', function()
  terminal('vnew')
end)

cmd('Tterm', function()
  terminal('tabnew')
end)

cmd('PackageUpdate', function(data)
  package.update(data.fargs[1])
end, { nargs = '?', complete = package.names })

cmd('PackageClean', function()
  package.clean()
end)

cmd('Workspace', function(data)
  workspace.open(data.fargs[1])
end, { nargs = 1, complete = workspace.names })

cmd('Cd', function(data)
  workspace.cd(data.fargs[1])
end, { nargs = 1, complete = 'file' })

return M
