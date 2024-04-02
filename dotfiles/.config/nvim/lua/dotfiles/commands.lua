local package = require('dotfiles.package')
local util = require('dotfiles.util')
local M = {}

local function cmd(name, func, opts)
  vim.api.nvim_create_user_command(name, func, opts or {})
end

local function terminal(modifier)
  vim.cmd(modifier and modifier .. ' term' or 'term')
  vim.cmd.startinsert()
end

cmd('Term', function()
  terminal('horizontal')
end)

cmd('Vterm', function()
  terminal('vertical')
end)

cmd('Tterm', function()
  vim.cmd.tabnew()
  terminal()
end)

cmd('PackageUpdate', function(data)
  package.update(data.fargs[1])
end, { nargs = '?', complete = package.names })

cmd('PackageClean', function()
  package.clean()
end)

cmd('Cd', function(data)
  local path = data.fargs[1]

  vim.cmd.cd(path)
  vim.cmd.Tterm()
  vim.cmd.stopinsert()
  vim.cmd.tabprev()
end, { nargs = 1, complete = 'file' })

cmd('Config', function()
  vim.cmd.Cd('~/Projects/general/dotfiles/dotfiles/.config/nvim')
end)

return M
