-- Configuration for NeoVim's LSP integration.

local config = require('lspconfig')

-- Enable support for LSP snippets
local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Configure how/when diagnostics are displayed
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    underline = false,
    virtual_text = false,
    signs = true,
    update_in_insert = false
  }
)

-- Routes LSP diagnostics to ALE
--
-- This is based on https://github.com/nathunsmitty/nvim-ale-diagnostic, with
-- some extra enhancements.
local ale_diagnostic_severity_map = {
  [vim.lsp.protocol.DiagnosticSeverity.Error] = 'E';
  [vim.lsp.protocol.DiagnosticSeverity.Warning] = 'W';
  [vim.lsp.protocol.DiagnosticSeverity.Information] = 'I';
  [vim.lsp.protocol.DiagnosticSeverity.Hint] = 'I';
}

local lsp_original_clear = vim.lsp.diagnostic.clear

vim.lsp.diagnostic.clear = function(bufnr, client_id, diagnostic_ns, sign_ns)
  lsp_original_clear(bufnr, client_id, diagnostic_ns, sign_ns)

  vim.api.nvim_call_function(
    'ale#other_source#ShowResults',
    { bufnr, 'nvim-lsp', {} }
  )
end

vim.lsp.diagnostic.set_signs = function(diagnostics, bufnr, _, _, _)
  if not diagnostics then
    return
  end

  local items = {}

  for _, item in ipairs(diagnostics) do
    -- We only want errors and warnings, as hints/informal messages are almost
    -- always just noise.
    if item.severity <= vim.lsp.protocol.DiagnosticSeverity.Warning then
      table.insert(
        items,
        {
          nr = item.code,
          text = item.message,
          lnum = item.range.start.line+1,
          end_lnum = item.range['end'].line,
          col = item.range.start.character+1,
          end_col = item.range['end'].character,
          type = ale_diagnostic_severity_map[item.severity]
        }
      )
    end
  end

  vim.api.nvim_call_function(
    'ale#other_source#ShowResults',
    { bufnr, 'nvim-lsp', items }
  )
end

-- Rust
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

-- Python
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

-- Go
config.gopls.setup {
  capabilities = capabilities,
  flags = {
    allow_incremental_sync = true
  },
}
