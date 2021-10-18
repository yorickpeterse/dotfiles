-- Configuration for NeoVim's LSP integration.

local config = require('lspconfig')
local lsp = vim.lsp
local vim_diag = vim.diagnostic
local api = vim.api
local fn = vim.fn
local diag = require('dotfiles.diagnostics')
local util = require('dotfiles.util')
local flags = {
  allow_incremental_sync = true,
  debounce_text_changes = 150
}

-- Markdown popup {{{1
do
  local default = lsp.util.open_floating_preview

  lsp.util.open_floating_preview = function(contents, syntax, opts)
    local local_opts = {
      max_width = 120,
      max_height = 20,
      separator = false
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
      vim.tbl_deep_extend('force', opts or {}, { border = 'single' })

    return default(width, height, new_opts)
  end
end

-- Snippet support {{{1
local capabilities = lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Diagnostics {{{1
vim_diag.config({
  underline = {
    severity = { min = vim_diag.severity.WARN }
  },
  signs = {
    severity = { min = vim_diag.severity.WARN }
  },
  severity_sort = true,
  virtual_text = false,
  update_in_insert = true
})

-- This ensures diagnostics are completely ignored when in insert mode, meaning
-- we don't need to handle it on a case by case basis. For example, diagnostics
-- displayed in the statusline aren't updated until leaving insert mode.
lsp.handlers['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
  if fn.pumvisible() == 1 or util.in_insert_mode() then
    diag.cache(result, ctx, config)
  else
    lsp.diagnostic.on_publish_diagnostics(nil, result, ctx, config)
  end
end

-- Signs {{{1
vim.fn.sign_define({
  {
    name = 'DiagnosticSignError',
    text = 'E',
    numhl = 'DiagnosticError',
    texthl = 'DiagnosticError'
  },
  {
    name = 'DiagnosticSignWarn',
    text = 'W',
    numhl = 'DiagnosticWarn',
    texthl = 'DiagnosticWarn'
  },
  {
    name = 'DiagnosticSignHint',
    text = 'H',
    numhl = 'DiagnosticHint',
    texthl = 'DiagnosticHint'
  },
  {
    name = 'DiagnosticSignInfo',
    text = 'H',
    numhl = 'DiagnosticInfo',
    texthl = 'DiagnosticInfo'
  },
})

-- Completion symbols {{{1
local lsp_symbols = {
  Class = 'Class',
  Color = 'Color',
  Constant = 'Constant',
  Constructor = 'Constructor',
  Enum = 'Enum',
  EnumMember = 'Member',
  File = 'File',
  Folder = 'Folder',
  Function = 'Function',
  Interface = 'Interface',
  Keyword = 'Keyword',
  Method = 'Method',
  Module = 'Module',
  Property = 'Property',
  Snippet = 'Snippet',
  Struct = 'Struct',
  Text = 'Text',
  Unit = 'Unit',
  Value = 'Value',
  Variable = 'Variable',
  Namespace = 'Namespace',
  Field = 'Field',
  Number = 'Number',
  TypeParameter = 'Type parameter'
}

for kind, symbol in pairs(lsp_symbols) do
  local kinds = lsp.protocol.CompletionItemKind
  local index = kinds[kind]

  if index ~= nil then
    kinds[index] = symbol
  end
end

-- C/C++ {{{1
config.clangd.setup {
  capabilities = capabilities,
  flags = flags,
}

-- Go {{{1
config.gopls.setup {
  capabilities = capabilities,
  flags = flags,
}

-- Lua {{{1
do
  local rpath = vim.split(package.path, ';')

  table.insert(rpath, 'lua/?.lua')
  table.insert(rpath, 'lua/?/init.lua')

  config.sumneko_lua.setup {
    capabilities = capabilities,
    flags = flags,
    cmd = {
      '/usr/bin/lua-language-server',
      '-E',
      '/usr/lib/lua-language-server/main.lua'
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
      }
    },
  }
end

-- Python {{{1
config.jedi_language_server.setup {
  capabilities = capabilities,
  flags = flags,
  init_options = {
    markupKindPreferred = 'markdown',
    startupMessage = false,
    diagnostics = {
      -- Linting as you type is distracting, and thus is disabled.
      didChange = false
    }
  }
}

-- Rust {{{1
config.rust_analyzer.setup {
  root_dir = config.util.root_pattern('Cargo.toml', 'rustfmt.toml'),
  capabilities = capabilities,
  flags = flags,
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        -- Disable diagnostics while typing, as this is rather annoying.
        -- Diagnostics are still produced when loading/writing a file.
        enable = false,
        enableExperimental = false
      },
      inlayHints = {
        typeHints = false,
        chainingHints = false,
        enable = false
      },
      server = {
        path = "/usr/bin/rust-analyzer"
      },
      lruCapacity = 64,
      completion = {
        postfix = {
          enable = false
        }
      }
    }
  }
}

-- vim: set foldmethod=marker:
