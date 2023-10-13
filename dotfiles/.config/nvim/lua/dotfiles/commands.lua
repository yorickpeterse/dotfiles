local M = {}
local fn = vim.fn

local function cmd(name, action, flags)
  local flag_pairs = {}

  if flags then
    for flag, value in pairs(flags) do
      if value == true then
        table.insert(flag_pairs, '-' .. flag)
      else
        table.insert(flag_pairs, '-' .. flag .. '=' .. value)
      end
    end
  end

  action = action:gsub('\n%s*', ' ')

  local def = table.concat(
    { 'command!', table.concat(flag_pairs, ' '), name, action },
    ' '
  )

  vim.cmd(def)
end

function M.terminal(cmd)
  vim.cmd(cmd)
  vim.wo.scrolloff = 0
  vim.cmd('term')
  vim.cmd('startinsert')
end

-- Terminals
cmd('Term', 'lua dotfiles.commands.terminal("new")')
cmd('Vterm', 'lua dotfiles.commands.terminal("vnew")')
cmd('Tterm', 'lua dotfiles.commands.terminal("tabnew")')

-- Package management
cmd(
  'PackageUpdate',
  'lua dotfiles.package.update(<f-args>)',
  { nargs = '?', complete = 'customlist,v:lua.dotfiles.package.names' }
)
cmd('PackageClean', 'lua dotfiles.package.clean()')
cmd('PackageEdit', 'e ~/.config/nvim/lua/dotfiles/packages.lua')

-- Workspace management
cmd(
  'Workspace',
  'lua dotfiles.workspace.open(<f-args>)',
  { nargs = '1', complete = 'customlist,v:lua.dotfiles.workspace.names' }
)

return M
