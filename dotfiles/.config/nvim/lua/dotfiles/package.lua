-- A small and opinionated package manager.
local reader = require('dotfiles.util').reader
local uv = vim.loop
local api = vim.api
local fn = vim.fn

local M = {}

-- The root directory to install all plugins into.
local root = vim.fn.stdpath('data') .. '/site/pack/packages/opt/'

-- All packages that have been registered.
local packages = {}

-- The total time (in milliseconds) to wait for packages to install.
local timeout = 10000

-- The progress bar title to use when installing packages.
local install_title = 'installing packages'

-- The progress bar title to use when updating packages.
local update_title = 'updating packages'

-- The progress bar title to use when removing packages.
local clean_title = 'removing packages'

-- Renders a progress bar to the command prompt.
local function progress(state)
  local current = state.done
  local total = state.total
  local empty = total - current
  local chars = string.rep('█', current) .. string.rep('░', empty)

  local lines = {
    { state.title .. ' [' .. current .. '/' .. total .. '] ' .. chars },
  }

  api.nvim_echo(lines, false, {})
  vim.cmd('redraw')
end

local function new_state(title, total)
  return { title = title, total = total, done = 0, failed = {} }
end

local function run_hook(package)
  local run = package.run
  local cwd = fn.getcwd()

  vim.cmd('cd ' .. package.dir)

  if type(run) == 'string' then
    vim.cmd(run)
  elseif type(run) == 'function' then
    run(package)
  end

  vim.cmd('cd ' .. cwd)

  -- Redraw after the command so we don't get any "Press enter to continue"
  -- prompts.
  vim.cmd('redraw')
end

local function finish(state)
  state.done = state.done + 1

  progress(state)
end

-- Runs a command.
local function spawn(opts)
  local handle
  local stderr = uv.new_pipe(false)
  local options = {
    args = opts.args,
    stdio = { nil, nil, stderr },
    detached = true,
    env = { GIT_TERMINAL_PROMPT = '0' },
  }

  handle, _ = uv.spawn(opts.cmd, options, function(code)
    handle:close()

    if code == 0 then
      vim.schedule(opts.success)
      return
    end

    if opts.error then
      stderr:read_start(reader(function(output)
        stderr:close()
        vim.schedule(function()
          opts.error(output)
        end)
      end))
    end
  end)

  return handle ~= nil
end

-- Shows the output of package failures in a buffer
local function show_failures(state)
  local lines = {}

  for package, output in pairs(state.failed) do
    table.insert(lines, package .. ':')
    table.insert(lines, '')

    for line in vim.gsplit(output, '\n') do
      table.insert(lines, line)
    end
  end

  if #lines == 0 then
    return
  end

  vim.cmd('vne')

  local bufnr = api.nvim_win_get_buf(0)

  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  api.nvim_set_option_value('modifiable', false, { buf = bufnr })
  api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
  api.nvim_set_option_value('modified', false, { buf = bufnr })

  api.nvim_buf_set_name(bufnr, 'Package errors')
end

-- Waits for all jobs to finish.
local function wait(state)
  vim.wait(timeout, function()
    return state.done == state.total
  end)
  show_failures(state)
  api.nvim_echo({}, false, {})
end

-- Returns `true` if the given package is installed.
local function installed(package)
  return #vim.fn.readdir(package.dir) > 0
end

local function helptags(package)
  local docs = package.dir .. '/doc'

  if fn.isdirectory(docs) == 1 then
    vim.cmd('helptags ' .. docs)
  end
end

-- Installs a single package.
local function install(package, state)
  local args = { 'clone', package.url, '--depth=1' }

  if package.branch then
    table.insert(args, '--branch')
    table.insert(args, package.branch)
  end

  table.insert(args, package.dir)

  spawn({
    cmd = 'git',
    args = args,
    success = function()
      state.done = state.done + 1

      progress(state)
      vim.cmd('packadd ' .. package.name)
      helptags(package)
      run_hook(package)
    end,
    error = function(output)
      state.done = state.done + 1

      progress(state)

      package.enable = false
      state.failed[package.name] = output
    end,
  })
end

-- Updates a single package
local function update(package, state)
  local kind = uv.fs_lstat(package.dir).type

  -- If a symbolic link is used it means I'm managing the package myself (e.g.
  -- it's linked to a local development version). In this case we don't want to
  -- update it.
  if kind == 'link' then
    finish(state)
    return
  end

  spawn({
    cmd = 'git',
    args = { '-C', package.dir, 'pull' },
    success = function()
      helptags(package)
      run_hook(package)
      finish(state)
    end,
    error = function(output)
      finish(state)

      state.failed[package.name] = output
    end,
  })
end

-- Removes an unrecognised directory
local function remove_directory(dir, state)
  spawn({
    cmd = 'rm',
    args = { '-rf', dir },
    success = function()
      state.done = state.done + 1

      progress(state)
    end,
    error = function(output)
      state.done = state.done + 1

      progress(state)

      state.failed[dir] = output
    end,
  })
end

-- Installs all packages pending installation.
local function install_pending()
  local done = 0
  local pending = {}

  for _, package in ipairs(packages) do
    if not installed(package) then
      table.insert(pending, package)
    end
  end

  if #pending == 0 then
    return
  end

  local state = new_state(install_title, #pending)

  progress(state)

  for _, package in ipairs(pending) do
    install(package, state)
  end

  wait(state)
end

-- Activates all installed packages
local function activate()
  for _, package in ipairs(packages) do
    if package.enable then
      vim.cmd('packadd ' .. package.name)
    end
  end
end

-- Registers a new package.
function M.use(spec)
  local url = nil
  local path = nil
  local options = {}

  if type(spec) == 'table' then
    path = table.remove(spec, 1)
    options = spec
  else
    path = spec
  end

  if path:match('http') or path:match('git@') then
    url = path
  else
    url = 'https://github.com/' .. path .. '.git'
  end

  if not url:match('.git$') then
    url = url .. '.git'
  end

  local name_chunks = vim.split(path, '/', { trimempty = false })
  local name = name_chunks[#name_chunks]:gsub('\\.git', '')

  assert(name, 'No package name could be derived from ' .. vim.inspect(path))

  local package = {
    name = name,
    dir = root .. name,
    url = url,
    enable = true,
    branch = options.branch,
    run = options.run,
  }

  table.insert(packages, package)
end

-- Installs all packages.
function M.install()
  install_pending()
  activate()
end

-- Updates all installed packages.
function M.update(to_update)
  local done = 0
  local pending = {}

  for _, package in ipairs(packages) do
    if installed(package) then
      if not to_update or to_update == package.name then
        table.insert(pending, package)
      end
    end
  end

  if #pending == 0 then
    return
  end

  local state = new_state(update_title, #pending)

  progress(state)

  for _, package in ipairs(pending) do
    update(package, state)
  end

  wait(state)
end

-- Returns a list of all installed package names.
function M.names(start)
  local names = {}

  for _, package in ipairs(packages) do
    if installed(package) then
      if not start or vim.startswith(package.name, start) then
        table.insert(names, package.name)
      end
    end
  end

  table.sort(names)

  return names
end

-- Removes all unrecognised packages
function M.clean()
  local known = {}
  local confirmed = {}

  for _, package in ipairs(packages) do
    known[package.dir] = true
  end

  for _, dir in ipairs(vim.fn.readdir(root)) do
    local path = root .. dir

    if
      not known[path]
      and vim.fn.confirm('Remove ' .. path, '&Yes\n&No', 2) == 1
    then
      table.insert(confirmed, path)
    end
  end

  if #confirmed == 0 then
    return
  end

  local state = new_state(clean_title, #confirmed)

  progress(state)

  for _, dir in ipairs(confirmed) do
    remove_directory(dir, state)
  end

  wait(state)
end

return M
