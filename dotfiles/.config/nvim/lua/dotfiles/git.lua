local api = vim.api
local fn = vim.fn
local uv = vim.uv
local Job = require('plenary.job')
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

--- The path to the .git directory of the current project.
local DIRECTORY = '.'

local function find_git_directory()
  return fn.finddir('.git', fn.getcwd() .. ';')
end

local function project_directory()
  return fn.resolve(DIRECTORY .. '/..')
end

local function git(args, on_success)
  Job:new({
    command = 'git',
    args = args,
    cwd = project_directory(),
    on_exit = function(job, status)
      if status == 0 then
        if on_success then
          on_success(job)
        end
      else
        util.error(table.concat(job:stderr_result(), ' '))
      end
    end,
  }):start()
end

local function update_branch()
  git({ 'rev-parse', '--abbrev-ref', 'HEAD' }, function(job)
    local out = job:result()

    BRANCH = out[1]
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
  else
    update_branch()
  end

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

local function notify(message)
  PROGRESS = message
  vim.schedule(function()
    vim.cmd.redrawstatus()
  end)
end

local function define_git_command()
  vim.api.nvim_create_user_command('Git', function(data)
    local cmd = data.fargs[1]
    local arg = data.fargs[2]

    if cmd == 'checkout' then
      if arg then
        M.checkout(arg)
      else
        util.error('a ref name is required')
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
      M.log(arg, data.fargs[3])
    else
      util.error("the command '" .. cmd .. "' isn't recognized")
    end
  end, {
    nargs = '+',
    complete = function(prefix, start, _)
      local cmd = vim.split(start, '%s+', { trimempty = true })[2]
      local data = nil

      if cmd == 'checkout' or cmd == 'log' then
        data = M.branches()
      else
        data = { 'checkout', 'log', 'pull', 'pull!', 'push', 'push!' }
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
  git(args, function()
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
  git(args, function()
    notify('')
  end)
end

function M.checkout(branch)
  git({ 'checkout', branch })
end

function M.branches()
  local out, status = Job:new({
    command = 'git',
    args = { 'branch', '--format=%(refname:short)' },
    cwd = DIRECTORY,
  }):sync()

  if status == 0 then
    table.sort(out, function(a, b)
      return a < b
    end)
    return out
  else
    return {}
  end
end

function M.log(start, stop)
  log.open(start, stop)
end

return M
