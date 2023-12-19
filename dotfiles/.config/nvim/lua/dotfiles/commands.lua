local package = require('dotfiles.package')
local workspace = require('dotfiles.workspace')
local util = require('dotfiles.util')
local M = {}

local function cmd(name, func, opts)
  vim.api.nvim_create_user_command(name, func, opts or {})
end

local function terminal(modifier)
  vim.wo.scrolloff = 0
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

cmd('Workspace', function(data)
  workspace.open(data.fargs[1])
end, { nargs = 1, complete = workspace.names })

cmd('Cd', function(data)
  workspace.cd(data.fargs[1])
end, { nargs = 1, complete = 'file' })

cmd('Git', function(data)
  require('dotfiles.git.log').open(data.fargs[1])
end, {
  nargs = '?',
  complete = function()
    local res = vim
      .system({ 'git', 'branch', '--format=%(refname:short)' }, { text = true })
      :wait()

    if res.code ~= 0 then
      return {}
    end

    local names = vim.split(res.stdout, '\n', { trimempty = true })

    table.sort(names, function(a, b)
      return a < b
    end)

    return names
  end,
})

return M
