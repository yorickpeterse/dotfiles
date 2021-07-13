-- Linting of files and publishing of the results as LSP diagnostics.
--
-- This is a custom linter setup, based on
-- https://github.com/mfussenegger/nvim-lint/. I'm using a custom setup so I can
-- more easily tweak it to my own liking.
local util = require('dotfiles.util')
local reader = util.reader
local error = util.error
local api = vim.api
local uv = vim.loop

local M = {}
local linters = {}

-- Callback for parsing and publishing a linter's diagnostics.
local function done(bufnr, linter, client_id, output)
  vim.schedule(function()
    local ok, items = pcall(linter.parse, output)

    if not ok then
      local err = vim.inspect(items)

      error('linter ' .. linter.name .. ' produced a parser error: ' .. err)
      return
    end

    local method = 'textDocument/publishDiagnostics'
    local result = {
      uri = vim.uri_from_bufnr(bufnr),
      diagnostics = items
    }

    vim.lsp.handlers[method](nil, method, result, client_id, bufnr)
  end)
end

-- Runs a single linter on a buffer.
local function lint(bufnr, path, linter, client_id)
  if not linter.enable() then
    return
  end

  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local cmd, args = linter.exe(path)

  -- Some of the linters I use don't handle STDIN well (e.g. gitlint). Since I
  -- only lint when saving a file, writing to STDIN simply isn't supported.
  local opts = {
    args = args,
    stdio = { nil, stdout, stderr },
    cwd = vim.fn.getcwd(),
    detached = true
  }

  local handle
  local pid_or_err

  handle, pid_or_err = uv.spawn(cmd, opts, function(code)
    stdout:close()
    stderr:close()
    handle:close()

    if linter.ignore_exitcode then
      return
    end

    if not vim.tbl_contains(linter.exit_codes, code) then
      error(linter.name .. ' exited with exit code: ' .. code)
    end
  end)

  if not handle then
    stdout:close()
    stderr:close()
    error('Failed to run linter ' .. linter.name .. ': ' .. pid_or_err)

    return
  end

  local stream = linter.stream == 'stdout' and stdout or stderr

  stream:read_start(reader(function(output)
    done(bufnr, linter, client_id, output)
  end))
end

-- Adds a new linter for the given filetype.
function M.linter(filetype, linter)
  if not linters[filetype] then
    linters[filetype] = {}
  end

  linter.stream = linter.stream or 'stdout'
  linter.enable = linter.enable or function() return true end
  linter.exit_codes = linter.exit_codes or { 0, 1 }

  assert(linter.name, 'Linters must define a name')
  assert(linter.exe, 'Linters must define an "exe" function')
  assert(linter.parse, 'Linters must define a "parse" function')

  table.insert(linters[filetype], linter)
end

-- Runs all linters for the current buffer.
function M.lint()
  local bufnr = api.nvim_get_current_buf()
  local ft = api.nvim_buf_get_option(bufnr, 'filetype')
  local linters = linters[ft]

  -- Language server clients need a unique ID. We don't set up an actual client
  -- though, so instead we use fake IDs. The offset here is to reduce the
  -- chances of the ID conflicting with an existing one. The value is arbitrary.
  local client_id = 0xbeef

  if not linters then
    return
  end

  local path = api.nvim_buf_get_name(bufnr)

  for i, linter in ipairs(linters) do
    lint(bufnr, path, linter, client_id + i)
  end
end

return M
