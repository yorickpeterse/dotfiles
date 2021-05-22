-- A small and opinionated package manager.
local M = {}
local uv = vim.loop
local api = vim.api

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

-- Returns a function for reading output from an output stream.
local function reader(done)
  local output = ''

  return function(err, chunk)
    if chunk then
      output = output .. chunk
    else
      done(output)
    end
  end
end

local function new_state(title, total)
  return { title = title, total = total, done = 0, failed = {} }
end

-- Runs a command.
local function spawn(opts)
  local handle
  local stderr = uv.new_pipe(false)

  handle, _ = uv.spawn(
    opts.cmd,
    {
      args = opts.args,
      stdio = { nil, nil, stderr },
      detached = true,
      env = { GIT_TERMINAL_PROMPT = '0' }
    },
    function(code)
      handle:close()

      if code == 0 then
        vim.schedule(opts.success)
        return
      end

      if opts.error then
        stderr:read_start(reader(function(output)
          stderr:close()
          vim.schedule(function() opts.error(output) end)
        end))
      end
    end
  )

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
  api.nvim_buf_set_option(bufnr, 'modifiable', false)
  api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(bufnr, 'modified', false)

  api.nvim_buf_set_name(bufnr, 'Package errors')
end

-- Waits for all jobs to finish.
local function wait(state)
  vim.wait(timeout, function() return state.done == state.total end)
  vim.cmd('helptags ALL')
  show_failures(state)
  api.nvim_echo({}, false, {})
end

-- Returns `true` if the given package is installed.
local function installed(package)
  return #vim.fn.readdir(package.dir) > 0
end

-- Installs a single package.
local function install(package, state)
  spawn({
    cmd = 'git',
    args = {
      'clone',
      package.url,
      '--depth=1',
      '--branch',
      package.branch,
      package.dir
    },
    success = function()
      state.done = state.done + 1

      progress(state)
      vim.cmd('packadd ' .. package.name)
    end,
    error = function(output)
      state.done = state.done + 1

      progress(state)

      packages[package.name].enable = false
      state.failed[package.name] = output
    end
  })
end

-- Updates a single package
local function update(package, state)
  spawn({
    cmd = 'git',
    args = { '-C', package.dir, 'pull' },
    success = function()
      state.done = state.done + 1

      progress(state)
    end,
    error = function(output)
      state.done = state.done + 1

      progress(state)

      state.failed[package.name] = output
    end
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
    end
  })
end

-- Installs all packages pending installation.
local function install_pending()
  local done = 0
  local pending = {}

  for _, package in pairs(packages) do
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
  for _, package in pairs(packages) do
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

  local name_chunks = vim.split(path, '/', true)
  local name = name_chunks[#name_chunks]:gsub('\\.git', '')

  assert(name, 'No package name could be derived from ' .. vim.inspect(path))

  packages[name] = {
    name = name,
    dir = root .. name,
    url = url,
    enable = true,
    branch = options.branch or 'master'
  }
end

-- Installs all packages.
function M.install()
  install_pending()
  activate()
end

-- Updates all installed packages.
function M.update()
  local done = 0
  local pending = {}

  for _, package in pairs(packages) do
    if installed(package) then
      table.insert(pending, package)
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

-- Removes all unrecognised packages
function M.clean()
  local known = {}
  local confirmed = {}

  for _, package in pairs(packages) do
    known[package.dir] = true
  end

  for _, dir in ipairs(vim.fn.readdir(root)) do
    local path = root .. dir

    if not known[path]
        and vim.fn.confirm('Remove ' .. path, "&Yes\n&No", 2) == 1 then
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
