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
    condition = function(a, b)
      return fn.executable(cmd) == 1
    end,
    generator = helpers.generator_factory({
      command = cmd,
      args = function(params)
        local path = fn.fnamemodify(params.bufname, ':p')
        local test = util.find_directory('test', params.bufname)
        local args = { 'check', '--format', 'json', '$FILENAME' }

        if vim.startswith(path, test) and test ~= '' then
          table.insert(args, '--include')
          table.insert(args, test)
        end

        return args
      end,
      to_stdin = false,
      to_temp_file = false,
      from_stderr = true,
      use_cache = false,
      format = 'json',
      multiple_files = true,
      on_output = function(params)
        local diagnostics = {}

        if fn.filereadable(params.bufname) == 0 then
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
            filename = diag.file,
          })
        end

        return diagnostics
      end,
      cwd = function(params)
        if params.bufname:match('/std/') then
          local std = fn.fnamemodify(
            fn.finddir('std', fn.fnamemodify(params.bufname, ':h') .. ';'),
            ':p'
          )

          if std ~= '' then
            return std
          end
        end

        return params.root
      end,
    }),
  }
end

return M
