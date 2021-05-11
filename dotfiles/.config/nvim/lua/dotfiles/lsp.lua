-- Configuration for NeoVim's LSP integration.

local config = require('lspconfig')

-- Customise the Markdown hover popup. This is a hack, but sadly NeoVim doesn't
-- offer an easier way at this time.
local old_markdown = vim.lsp.util.fancy_floating_markdown

vim.lsp.util.fancy_floating_markdown = function(contents, opts)
  local local_opts = {
    max_width = 120,
    max_height = 20,
    separator = false
  }

  local combined_opts = vim.tbl_deep_extend('force', opts or {}, local_opts)

  return old_markdown(contents, combined_opts)
end

-- This enables a border for all LSP related floating windows.
local old_make_opts = vim.lsp.util.make_floating_popup_options

vim.lsp.util.make_floating_popup_options = function(width, height, opts)
  local new_opts =
    vim.tbl_deep_extend('force', opts or {}, { border = 'single' })

  return old_make_opts(width, height, new_opts)
end

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

-- Set up symbols for LSP completion.
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
          -- ALE doesn't handle newlines in messages very well, so we only send
          -- over the first line.
          text = vim.split(item.message, "\n", true)[1],
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
