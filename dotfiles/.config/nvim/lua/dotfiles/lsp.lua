local config = require('lspconfig')
local lsp = vim.lsp
local vim_diag = vim.diagnostic
local api = vim.api
local fn = vim.fn
local diag = require('dotfiles.diagnostics')
local util = require('dotfiles.util')
local nls = require('null-ls')
local flags = {
  allow_incremental_sync = true,
  debounce_text_changes = 500,
}

lsp.set_log_level('ERROR')

-- Markdown popup {{{1
do
  local default = lsp.util.open_floating_preview

  lsp.util.open_floating_preview = function(contents, syntax, opts)
    local local_opts = {
      max_width = 120,
      max_height = 20,
      separator = false,
    }

    local combined_opts = vim.tbl_deep_extend('force', opts or {}, local_opts)

    return default(contents, syntax, combined_opts)
  end
end

-- Floating window borders {{{1
do
  local default = lsp.util.make_floating_popup_options

  lsp.util.make_floating_popup_options = function(width, height, opts)
    local new_opts =
      vim.tbl_deep_extend('force', opts or {}, { border = 'rounded' })

    return default(width, height, new_opts)
  end
end

-- Snippet support {{{1
local capabilities = lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Diagnostics {{{1
vim_diag.config({
  underline = false,
  signs = {
    severity = { min = vim_diag.severity.WARN },
  },
  float = {
    severity = { min = vim_diag.severity.WARN },
  },
  severity_sort = true,
  virtual_text = false,
  update_in_insert = true,
})

-- Signs {{{1
vim.fn.sign_define({
  {
    name = 'DiagnosticSignError',
    text = '❙',
    numhl = 'DiagnosticError',
    texthl = 'DiagnosticError',
  },
  {
    name = 'DiagnosticSignWarn',
    text = '❙',
    numhl = 'DiagnosticWarn',
    texthl = 'DiagnosticWarn',
  },
  {
    name = 'DiagnosticSignHint',
    text = '❙',
    numhl = 'DiagnosticHint',
    texthl = 'DiagnosticHint',
  },
  {
    name = 'DiagnosticSignInfo',
    text = '❙',
    numhl = 'DiagnosticInfo',
    texthl = 'DiagnosticInfo',
  },
})

-- C/C++ {{{1
config.clangd.setup({
  capabilities = capabilities,
  flags = flags,
})

-- Go {{{1
config.gopls.setup({
  capabilities = capabilities,
  flags = flags,
  settings = {
    gopls = {
      usePlaceholders = true,
    },
  },
})

-- Lua {{{1
do
  local rpath = vim.split(package.path, ';')
  local runtime_files = vim.api.nvim_list_runtime_paths()

  table.insert(rpath, 'lua/?.lua')
  table.insert(rpath, 'lua/?/init.lua')

  config.sumneko_lua.setup({
    capabilities = capabilities,
    flags = flags,
    cmd = {
      '/usr/bin/lua-language-server',
      '-E',
      '/usr/lib/lua-language-server/main.lua',
    },
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = rpath,
        },
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          library = runtime_files,
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
end

-- null-ls {{{1
do
  local sources = require('dotfiles.null_ls')
  local root_path = util.path_relative_to_lsp_root

  nls.setup({
    debounce = 1000,
    log_level = 'off',
    sources = {
      -- Linters
      sources.rubocop(),
      sources.gitlint(),
      sources.inko(),
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
      nls.builtins.formatting.black,
    },
  })
end

-- Python {{{1
config.jedi_language_server.setup({
  capabilities = capabilities,
  flags = flags,
  init_options = {
    markupKindPreferred = 'markdown',
    startupMessage = false,
    diagnostics = {
      didChange = true,
    },
  },
})

-- Rust {{{1
config.rust_analyzer.setup({
  capabilities = capabilities,
  flags = flags,
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = true,
        enableExperimental = false,
      },
      inlayHints = {
        typeHints = false,
        chainingHints = false,
        enable = false,
      },
      server = {
        path = '/usr/bin/rust-analyzer',
      },
      lruCapacity = 64,
      completion = {
        postfix = {
          enable = false,
        },
      },
    },
  },
})

-- vim: set foldmethod=marker:
