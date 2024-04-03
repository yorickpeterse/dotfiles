local api = vim.api
local fn = vim.fn
local uv = vim.uv
local util = require('dotfiles.util')
local log = require('dotfiles.git.log')
local M = {}

local AUGROUP = api.nvim_create_augroup('dotfiles_git', {})

-- The event to use for watching the .git directory
local WATCHER = nil

-- The name of the current Git branch.
local BRANCH = ''

-- A string describing what we're currently doing.
local PROGRESS = ''

-- The path to the .git directory of the current project.
local DIRECTORY = '.'

-- The editor command to use for interactive Git operations.
local EDITOR = 'nvr -cc vsplit -c "setlocal bufhidden=wipe" --remote-wait'

local function find_git_directory()
  return fn.finddir('.git', fn.getcwd() .. ';')
end

local function project_directory()
  return fn.resolve(DIRECTORY .. '/..')
end

local function notify(message)
  PROGRESS = message
  vim.schedule(function()
    vim.cmd.redrawstatus()
  end)
end

local function git(opts, on_success)
  local cmd = { 'git' }
  local env = { cwd = project_directory() }

  if opts.args then
    for _, arg in ipairs(opts.args) do
      table.insert(cmd, arg)
    end
  end

  if opts.env then
    env = vim.tbl_extend('force', env, opts.env)
  end

  vim.system(cmd, env, function(result)
    if result.code == 0 then
      if on_success then
        on_success(vim.trim(result.stdout))
      end
    else
      notify('')
      util.error(vim.trim(result.stderr))
    end
  end)
end

local function update_branch()
  git({ args = { 'branch', '--show-current' } }, function(name)
    BRANCH = name
    vim.schedule(function()
      vim.cmd.redrawstatus()
    end)
  end)
end

local function unwatch_branch()
  if WATCHER then
    WATCHER:stop()
    WATCHER = nil
  end

  BRANCH = ''
end

local function watch_branch()
  if WATCHER then
    unwatch_branch()
  end

  update_branch()

  WATCHER = assert(uv.new_fs_event())
  WATCHER:start(
    DIRECTORY,
    {},
    vim.schedule_wrap(function(err, file, events)
      if events.change and file == 'HEAD.lock' then
        update_branch()
      end
    end)
  )
end

local function working_directory_changed()
  DIRECTORY = find_git_directory()

  if #DIRECTORY > 0 then
    watch_branch()
  else
    unwatch_branch()
  end

  -- This isn't strictly necessary, but calling `redrawstatus` directly when
  -- starting up results in some flickering.
  vim.schedule(function()
    vim.cmd.redrawstatus()
  end)
end

local function watch_working_directory()
  working_directory_changed()
  api.nvim_create_autocmd('DirChanged', {
    pattern = 'global',
    group = AUGROUP,
    callback = working_directory_changed,
  })
end

local function handle_user_command(args)
  local cmd = args[1]
  local arg = args[2]

  if cmd == 'checkout' then
    if arg then
      M.checkout(arg)
    else
      util.error('a ref name is required')
    end
  elseif cmd == 'merge' then
    if arg then
      M.merge(arg)
    else
      util.error('a branch name is required')
    end
  elseif cmd == 'push' then
    M.push()
  elseif cmd == 'push!' then
    M.push({ force = true })
  elseif cmd == 'pull' then
    M.pull()
  elseif cmd == 'pull!' then
    M.pull({ force = true })
  elseif cmd == 'log' then
    M.log(arg, args[3])
  elseif cmd == 'commit' then
    M.commit()
  elseif cmd == 'commit!' then
    M.commit({ amend = true })
  else
    util.error("the command '" .. cmd .. "' isn't recognized")
  end
end

local function define_git_command()
  vim.api.nvim_create_user_command('Git', function(data)
    handle_user_command(data.fargs)
  end, {
    nargs = '+',
    complete = function(prefix, start, _)
      local cmd = vim.split(start, '%s+', { trimempty = true })[2]
      local data = nil

      if cmd == 'checkout' or cmd == 'log' or cmd == 'merge' then
        data = M.branches()
      else
        data = {
          'checkout',
          'commit',
          'commit!',
          'log',
          'merge',
          'pull',
          'pull!',
          'push',
          'push!',
        }
      end

      return vim.tbl_filter(function(item)
        return vim.startswith(item, prefix)
      end, data)
    end,
  })
end

function M.setup()
  define_git_command()
  watch_working_directory()
end

function M.branch()
  return BRANCH
end

function M.progress()
  return PROGRESS
end

function M.pull(opts)
  local args = { 'pull', 'origin', BRANCH }

  if opts then
    if opts.force then
      table.insert(args, '--rebase')
    end
  end

  notify('pulling from ' .. BRANCH)
  git({ args = args }, function()
    notify('')
  end)
end

function M.push(opts)
  local args = { 'push', 'origin', BRANCH }

  if opts then
    if opts.force then
      table.insert(args, '--force-with-lease')
    end
  end

  notify('pushing to ' .. BRANCH)
  git({ args = args }, function()
    notify('')
  end)
end

function M.checkout(branch)
  git({ args = { 'checkout', branch } })
end

function M.branches()
  local result = vim
    .system(
      { 'git', 'branch', '--format=%(refname:short)' },
      { cwd = project_directory() }
    )
    :wait()

  if result.code == 0 then
    local lines = vim.split(result.stdout, '\n', { trimempty = true })

    table.sort(lines, function(a, b)
      return a < b
    end)
    return lines
  else
    return {}
  end
end

function M.log(start, stop)
  log.open(start, stop)
end

function M.commit(opts)
  local cmd = { 'git', 'commit' }

  if opts then
    if opts.amend then
      table.insert(cmd, '--amend')
    end
  end

  vim.system(cmd, { env = { GIT_EDITOR = EDITOR } }, function(result)
    if result.code ~= 0 then
      util.error(vim.trim(result.stderr))
    end
  end)
end

function M.merge(branch)
  notify('merging ' .. branch)
  git({ args = { 'merge', '--ff-only', branch } }, function()
    notify('')
  end)
end

return M
