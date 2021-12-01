local fn = vim.fn
local M = {}

-- The symbolic links to create for every `bwrap` command.
local symlinks = {
  ['/bin'] = 'usr/bin',
  ['/sbin'] = 'usr/bin',
  ['/lib'] = 'usr/lib',
  ['/lib64'] = 'usr/lib',
}

-- The default/base arguments to use for every `bwrap` command.
local default_args = {
  '--dev',
  '/dev',
  '--proc',
  '/proc',
  '--tmpfs',
  '/tmp',
  '--unshare-pid',
  '--clearenv',
  '--die-with-parent',
}

-- The environment variables to always expose to the command. This list should
-- be limited to only the essentials.
local default_env = {
  'HOME',
  'LANG',
  'LC_MONETARY',
  'LC_NUMERIC',
  'LC_TIME',
  'PATH',
  'PWD',
  'SHELL',
  'USER',
}

-- Paths that should be mounted as read-only by default. This list should be
-- limited to paths that pretty much every command is going to need.
local default_read_only = {
  '/usr',
  '/etc/resolv.conf',
  '/etc/ca-certificates',
  '/etc/ssl',
}

local function add_mount(cmd, path, write)
  local absolute = fn.fnamemodify(path, ':p')
  local option = write and '--bind' or '--ro-bind'

  if fn.isdirectory(absolute) == 1 or fn.filereadable(absolute) == 1 then
    table.insert(cmd, option)
    table.insert(cmd, absolute)
    table.insert(cmd, absolute)
  end
end

-- Generates a table that contains the `bwrap` command and all the arguments
-- necessary to run a custom command.
--
-- The following options are available:
--
-- - `read_only`: a list of paths to mount as read-only
-- - `read_write`: a list of paths to mount as read-write
-- - `cmd`: the command and its base arguments to run using `bwrap`
-- - `env`: a list of variable names to expose to the command
--
-- The paths are expanded using `fnamemodify()`.
--
-- Network access is denied by default.
--
-- Example:
--
--     wrap({ cmd = { 'ls' }, read_only = { '~/' } })
function M.wrap(options)
  local cmd = { 'bwrap' }

  for _, path in ipairs(default_read_only) do
    add_mount(cmd, path)
  end

  for target, source in pairs(symlinks) do
    table.insert(cmd, '--symlink')
    table.insert(cmd, source)
    table.insert(cmd, target)
  end

  for _, arg in ipairs(default_args) do
    table.insert(cmd, arg)
  end

  if options.read_write then
    for _, path in ipairs(options.read_write) do
      add_mount(cmd, path, true)
    end
  end

  if options.read_only then
    for _, path in ipairs(options.read_only) do
      add_mount(cmd, path)
    end
  end

  local env = vim.deepcopy(default_env)

  if options.env then
    vim.list_extend(env, options.env)
  end

  for _, name in ipairs(env) do
    local value = os.getenv(name)

    if value then
      table.insert(cmd, '--setenv')
      table.insert(cmd, name)
      table.insert(cmd, value)
    end
  end

  if options.network then
    table.insert(cmd, '--share-net')
  else
    table.insert(cmd, '--unshare-net')
  end

  vim.list_extend(cmd, options.cmd)

  return cmd
end

return M
