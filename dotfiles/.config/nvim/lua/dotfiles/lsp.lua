-- Configuration for NeoVim's LSP integration.

local config = require('lspconfig')

-- Markdown popup {{{1
do
  local default = vim.lsp.util.fancy_floating_markdown

  vim.lsp.util.fancy_floating_markdown = function(contents, opts)
    local local_opts = {
      max_width = 120,
      max_height = 20,
      separator = false
    }

    local combined_opts = vim.tbl_deep_extend('force', opts or {}, local_opts)

    return default(contents, combined_opts)
  end
end

-- Floating window borders {{{1
do
  local default = vim.lsp.util.make_floating_popup_options

  vim.lsp.util.make_floating_popup_options = function(width, height, opts)
    local new_opts =
      vim.tbl_deep_extend('force', opts or {}, { border = 'single' })

    return default(width, height, new_opts)
  end
end

-- Snippet support {{{1
local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Diagnostics {{{1
do
  local event = 'textDocument/publishDiagnostics'
  local default = vim.lsp.handlers[event]
  local config = {
    underline = true,
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    severity_sort = true
  }

  local severities = {
    [vim.lsp.protocol.DiagnosticSeverity.Error] = 'E',
    [vim.lsp.protocol.DiagnosticSeverity.Warning] = 'W',
  }

  -- I'm using a custom handler for populating the location list. For some
  -- reason using vim.lsp.diagnostic.set_loclist() produces an empty location
  -- list; perhaps due to a timing issue of some sort.
  --
  -- In addition, using a custom handler makes it easier to customise the
  -- behaviour/format.
  vim.lsp.handlers[event] = function(err, method, result, client_id, unused, _)
    default(err, method, result, client_id, unused, config)

    local items = {}
    local bufnr = vim.api.nvim_get_current_buf()

    -- Multiple clients may produce diagnostics, so we add _all_ current
    -- diagnostics to the location list; instead of the diagnostics for the
    -- current callback.
    for _, diag in ipairs(vim.lsp.diagnostic.get(bufnr)) do
      if diag.severity <= vim.lsp.protocol.DiagnosticSeverity.Warning then
        table.insert(items, {
          bufnr = bufnr,
          lnum = diag.range.start.line + 1,
          col = diag.range.start.character + 1,
          text = diag.message,
          type = severities[diag.severity or vim.lsp.protocol.DiagnosticSeverity.Error] or 'E',
        })
      end
    end

    table.sort(items, function(a, b) return a.lnum < b.lnum end)

    vim.lsp.util.set_loclist(items)
  end
end

-- Signs {{{1
do
  local default = vim.lsp.diagnostic.set_signs
  local config = { severity_limit = 'Warning' }

  vim.lsp.diagnostic.set_signs = function(diagnostics, bufnr, client_id, sign_ns, _)
    default(diagnostics, bufnr, client_id, sign_ns, config)
  end
end

-- Completion symbols {{{1
local lsp_symbols = {
  Class = '𝗖',
  Color = '',
  Constant = '',
  Constructor = '',
  Enum = '𝗘',
  EnumMember = '',
  File = '',
  Folder = '',
  Function = '',
  Interface = 'ﰮ',
  Keyword = '',
  Method = '',
  Module = '',
  Property = '',
  Snippet = '',
  Struct = '',
  Text = '',
  Unit = '',
  Value = '',
  Variable = '',
  Namespace = '',
  Field = '',
  Number = '#',
  TypeParameter = '𝗧'
}

for kind, symbol in pairs(lsp_symbols) do
  local kinds = vim.lsp.protocol.CompletionItemKind
  local index = kinds[kind]

  if index ~= nil then
    kinds[index] = symbol
  end
end

-- Rust {{{1
config.rust_analyzer.setup {
  root_dir = config.util.root_pattern('Cargo.toml', 'rustfmt.toml'),
  capabilities = capabilities,
  flags = {
    allow_incremental_sync = true
  },
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

-- Python {{{1
config.jedi_language_server.setup {
  capabilities = capabilities,
  flags = {
    allow_incremental_sync = true
  },
  init_options = {
    markupKindPreferred = 'markdown',
    startupMessage = false,
    diagnostics = {
      -- Linting as you type is distracting, and thus is disabled.
      didChange = false
    }
  }
}

-- Go {{{1
config.gopls.setup {
  capabilities = capabilities,
  flags = {
    allow_incremental_sync = true
  },
}

-- vim: set foldmethod=marker:
