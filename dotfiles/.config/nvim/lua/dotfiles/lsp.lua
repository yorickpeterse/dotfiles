local config = require('lspconfig')
local lsp = vim.lsp
local vim_diag = vim.diagnostic
local api = vim.api
local fn = vim.fn
local diag = require('dotfiles.diagnostics')
local util = require('dotfiles.util')
local flags = {
  allow_incremental_sync = true,
  debounce_text_changes = 1000,
}

local function on_attach(client, bufnr)
  -- Redraw the tab line as soon as possible, so LSP client statuses show up;
  -- instead of waiting until the first time they publish a progress message.
  vim.cmd('redrawtabline')
end

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
    local new_opts = vim.tbl_deep_extend(
      'force',
      opts or {},
      { border = 'rounded' }
    )

    return default(width, height, new_opts)
  end
end

-- Snippet support {{{1
local capabilities = lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Diagnostics {{{1
vim_diag.config({
  underline = {
    severity = { min = vim_diag.severity.WARN },
  },
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
    text = 'E',
    numhl = 'DiagnosticError',
    texthl = 'DiagnosticError',
  },
  {
    name = 'DiagnosticSignWarn',
    text = 'W',
    numhl = 'DiagnosticWarn',
    texthl = 'DiagnosticWarn',
  },
  {
    name = 'DiagnosticSignHint',
    text = 'H',
    numhl = 'DiagnosticHint',
    texthl = 'DiagnosticHint',
  },
  {
    name = 'DiagnosticSignInfo',
    text = 'H',
    numhl = 'DiagnosticInfo',
    texthl = 'DiagnosticInfo',
  },
})

-- C/C++ {{{1
config.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  flags = flags,
})

-- Go {{{1
config.gopls.setup({
  on_attach = on_attach,
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

  table.insert(rpath, 'lua/?.lua')
  table.insert(rpath, 'lua/?/init.lua')

  config.sumneko_lua.setup({
    on_attach = on_attach,
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
          library = vim.api.nvim_get_runtime_file('', true),
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
end

-- null-ls {{{1
config['null-ls'].setup({
  on_attach = on_attach,
  capabilities = capabilities,
  flags = flags,
})

-- Python {{{1
config.jedi_language_server.setup({
  on_attach = on_attach,
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
  on_attach = on_attach,
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
