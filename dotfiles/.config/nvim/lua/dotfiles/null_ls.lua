local M = {}
local fn = vim.fn
local nls = require('null-ls')
local helpers = require('null-ls.helpers')
local util = require('dotfiles.util')
local root_path = util.path_relative_to_lsp_root

-- Caches (per LSP client) whether RuboCop should be run with Bundler or not.
local use_bundler_cache = {}

-- Returns `true` if RuboCop should run using `bundle exec`.
--
-- The result of this function is cached. This way we don't need to read
-- Gemfile.lock files every time RuboCop is run.
local function rubocop_with_bundler(client_id)
  return util.cached(use_bundler_cache, client_id, function()
    return util.use_bundler('rubocop', root_path(client_id, 'Gemfile.lock'))
  end)
end

function M.rubocop()
  local base_args = nls.builtins.diagnostics.rubocop._opts.args

  return nls.builtins.diagnostics.rubocop.with({
    command = 'ruby-exec',
    args = function(params)
      local args = vim.list_extend({ 'rubocop' }, base_args)

      if rubocop_with_bundler(params.client_id) == 2 then
        args = vim.list_extend({ 'bundle', 'exec' }, args)
      end

      return args
    end,
    runtime_condition = function(params)
      return rubocop_with_bundler(params.client_id) > 0
    end,
  })
end

function M.gitlint()
  return {
    method = nls.methods.DIAGNOSTICS,
    filetypes = { 'gitcommit' },
    generator = helpers.generator_factory({
      command = 'gitlint',
      args = { '--ignore-stdin', '--msg-filename', '$FILENAME' },
      to_stdin = false,
      to_temp_file = true,
      from_stderr = true,
      format = 'line',
      check_exit_code = function(code)
        return code <= 252
      end,
      on_output = helpers.diagnostics.from_pattern(
        '(%d+): %w+ ([^:]+)',
        { 'row', 'message' }
      ),
      runtime_condition = function(params)
        return util.file_exists(root_path(params.client_id, '.gitlint'))
      end,
    }),
  }
end

function M.inko()
  local cmd = 'inko'

  return {
    method = nls.methods.DIAGNOSTICS_ON_SAVE,
    filetypes = { 'inko' },
    condition = function()
      return fn.executable(cmd) == 1
    end,
    generator = helpers.generator_factory({
      command = cmd,
      args = function(params)
        local args = { 'check', '--format', 'json', '$FILENAME' }

        if params.bufname:match('/test/') then
          local tests = fn.fnamemodify(
            fn.finddir('test', fn.fnamemodify(params.bufname, ':h') .. ';'),
            ':p'
          )

          if tests ~= '' then
            table.insert(args, '--include')
            table.insert(args, tests)
          end
        end

        return args
      end,
      to_stdin = false,
      to_temp_file = false,
      from_stderr = true,
      use_cache = false,
      format = 'json',
      on_output = function(params)
        local diagnostics = {}

        -- Ignore the missing file error when opening a buffer not yet written
        -- to disk.
        if #params.output == 1 and params.output[1].id == 'invalid-file' then
          return diagnostics
        end

        for _, diag in ipairs(params.output) do
          table.insert(diagnostics, {
            row = diag.lines[1],
            end_row = diag.lines[2],
            col = diag.columns[1],
            end_col = diag.columns[2] + 1,
            severity = helpers.diagnostics.severities[diag.level],
            message = diag.message,
          })
        end

        return diagnostics
      end,
      cwd = function(params)
        if params.bufname:match('/libstd/') then
          local libstd = fn.fnamemodify(
            fn.finddir('libstd', fn.fnamemodify(params.bufname, ':h') .. ';'),
            ':p'
          )

          if libstd ~= '' then
            return libstd
          end
        end

        return params.root
      end,
    }),
  }
end

return M
