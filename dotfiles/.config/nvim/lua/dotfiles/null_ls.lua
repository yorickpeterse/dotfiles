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

local function rubocop()
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

local function gitlint()
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

local function inko()
  return {
    method = nls.methods.DIAGNOSTICS,
    filetypes = { 'inko' },
    generator = helpers.generator_factory({
      command = 'inko',
      args = function(params)
        local args = { 'build', '--format', 'json', '--check', '$FILENAME' }

        if params.bufname:match('/tests/test/') then
          local tests = fn.fnamemodify(
            fn.finddir('tests', fn.fnamemodify(params.bufname, ':h') .. ';'),
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
      format = 'json',
      on_output = helpers.diagnostics.from_json({
        attributes = {
          row = 'line',
          col = 'column',
          message = 'message',
          severity = 'level',
        },
        severities = {
          error = helpers.diagnostics.severities.error,
          warning = helpers.diagnostics.severities.warning,
        },
      }),
    }),
  }
end

nls.config({
  debounce = 1000,
  sources = {
    -- Linters
    rubocop(),
    gitlint(),
    inko(),
    nls.builtins.diagnostics.vale.with({
      runtime_condition = function(params)
        return util.file_exists(root_path(params.client_id, '.vale.ini'))
      end,
    }),
    nls.builtins.diagnostics.flake8,
    nls.builtins.diagnostics.shellcheck,

    -- Formatters
    nls.builtins.formatting.stylua.with({
      runtime_condition = function(params)
        return util.file_exists(root_path(params.client_id, 'stylua.toml'))
      end,
    }),
    nls.builtins.formatting.fish_indent,
  },
})
