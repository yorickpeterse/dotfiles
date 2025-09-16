local util = require('dotfiles.util')
local fn = vim.fn
local api = vim.api
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

cmd('Commits', function(data)
  require('dotfiles.git.log').open(data.fargs[1], data.fargs[2])
end, {
  nargs = '*',
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

cmd('Review', function(data)
  require('dotfiles.git.diff').show(data.fargs[1], data.fargs[2])
end, {
  nargs = '*',
  complete = function(prefix)
    local pat = tostring(prefix) .. '*'
    local candidates = {}
    local res = vim
      .system({
        'git',
        'for-each-ref',
        '--format=%(refname:strip=2)',
        'refs/remotes/*/' .. pat,
        'refs/heads' .. pat,
        'refs/tags/' .. pat,
      })
      :wait()

    for line in vim.gsplit(res.stdout, '\n', { trimempty = true }) do
      table.insert(candidates, line)
    end

    table.sort(candidates, function(a, b)
      return a < b
    end)

    return candidates
  end,
})

cmd('CloseBuffers', function()
  local now = os.time()

  for _, buf in ipairs(fn.getbufinfo({ buflisted = 1 })) do
    local typ = api.nvim_get_option_value('buftype', { buf = buf.bufnr })

    if
      now - buf.lastused >= 3600
      and buf.changed == 0
      and typ ~= 'terminal'
    then
      api.nvim_buf_delete(buf.bufnr, {})
    end
  end
end)

return M
