-- Configuration for NeoVim's LSP integration.

local config = require('lspconfig')

-- Markdown popup {{{1
do
  local default = vim.lsp.util.open_floating_preview

  vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
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
  local severities = {
    [vim.lsp.protocol.DiagnosticSeverity.Error] = 'E',
    [vim.lsp.protocol.DiagnosticSeverity.Warning] = 'W',
  }

  local function set_location_list(diagnostics, bufnr)
    local items = {}

    -- Multiple clients may produce diagnostics, so we add _all_ current
    -- diagnostics to the location list; instead of the diagnostics for the
    -- current callback.
    for _, diag in ipairs(diagnostics) do
      if diag.severity <= vim.lsp.protocol.DiagnosticSeverity.Warning then
        table.insert(items, {
          bufnr = bufnr,
          lnum = diag.range.start.line + 1,
          col = diag.range.start.character + 1,
          text = vim.split(diag.message, "\n")[1],
          type = severities[diag.severity or vim.lsp.protocol.DiagnosticSeverity.Error] or 'E',
        })
      end
    end

    table.sort(items, function(a, b) return a.lnum < b.lnum end)

    -- Using window ID 0 doesn't work reliably. For example, if diagnostics are
    -- being published while the active window is changed, we may end up setting
    -- the location list for the wrong window.
    --
    -- See https://github.com/neovim/neovim/issues/14639 for more details.
    local window = vim.fn.bufwinnr(bufnr)

    vim.fn.setloclist(window, {}, ' ', {
      title = 'Language Server',
      items = items,
    })
  end

  vim.lsp.handlers['textDocument/publishDiagnostics'] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      underline = true,
      virtual_text = false,
      signs = true,
      update_in_insert = false,
      severity_sort = true
    })

  local display = vim.lsp.diagnostic.display
  local timeout = 100
  local timeouts = {}

  -- This callback gets called _a lot_. Populating the location list every time
  -- can sometimes lead to empty or out of sync location lists. To prevent this
  -- from happening we defer updating the location list.
  vim.lsp.diagnostic.display = function(diagnostics, bufnr, client_id, config)
    display(diagnostics, bufnr, client_id, config)

    -- Timers are stored per buffer and client, otherwise diagnostics produced
    -- for one buffer/client may reset the timer of an unrelated buffer/client.
    if timeouts[bufnr] == nil then
      timeouts[bufnr] = {}

      -- Clear the cache when the buffer unloads
      vim.api.nvim_buf_attach(bufnr, false, {
        on_detach = function()
          timeouts[bufnr] = nil
        end
      })
    end

    if timeouts[bufnr][client_id] then
      timeouts[bufnr][client_id]:stop()
    end

    local callback = function()
      if diagnostics then
        set_location_list(diagnostics, bufnr)
      end
    end

    timeouts[bufnr][client_id] = vim.defer_fn(callback, timeout)
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
