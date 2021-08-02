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

cmd('Tq', 'windo q')
cmd('Init', 'e ~/.config/nvim/init.lua')
cmd(
  'Replace',
  'lua dotfiles.callbacks.find_replace_register(<f-args>)',
  { nargs = '+' }
)

-- FZF
cmd(
  'Files',
  [[
    call fzf#vim#files(
      <q-args>,
      {'options': ['--prompt=>> ', '--reverse', '--exact']},
      <bang>0
    )
  ]],
  { bang = true, nargs = '?', complete = 'dir'  }
)

cmd(
  'BTags',
  [[
    call fzf#vim#buffer_tags(
      <q-args>,
      'rg --color=never --no-filename --no-line-number '
        . fzf#shellescape(expand('%'))
        . ' tags | sort -s -t \t -k 1,1',
      {
        'placeholder': '{2}:{3}',
        'options': ['--prompt=>> ', '--reverse', '--no-sort', '--exact', '+i']
      },
      <bang>0
    )
  ]],
  { bang = true, nargs = '*' }
)

cmd(
  'Buffers',
  [[
    call fzf#vim#buffers(
      <q-args>,
      {
        'placeholder': '{1}',
        'options': ['--prompt=>> ', '--reverse', '--exact']
      },
      <bang>0
    )
  ]],
  { bang = true, bar = true, nargs = '?', complete = 'buffer'  }
)

-- Git
cmd('Review', 'lua dotfiles.callbacks.review()', { nargs = '?' })

-- Terminals
cmd('Term', 'lua dotfiles.callbacks.terminal("new")')
cmd('Vterm', 'lua dotfiles.callbacks.terminal("vnew")')
cmd('Tterm', 'lua dotfiles.callbacks.terminal("tabnew")')

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
