local config = require('lspconfig')
local lsp = vim.lsp
local vim_diag = vim.diagnostic
local api = vim.api
local fn = vim.fn
local diag = require('dotfiles.diagnostics')
local util = require('dotfiles.util')
local flags = {
  allow_incremental_sync = true,
  debounce_text_changes = 500,
}

lsp.set_log_level('OFF')

local capabilities = lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem.snippetSupport = true

local function on_attach(client, bufnr)
  -- Disabled due to https://github.com/neovim/neovim/issues/23164
  client.server_capabilities.semanticTokensProvider = nil
end

-- Markdown popup {{{1
do
  local default = lsp.util.open_floating_preview

  lsp.util.open_floating_preview = function(contents, syntax, opts)
    opts = opts or {}
    opts =
      vim.tbl_deep_extend('force', opts, { max_width = 120, max_height = 20 })

    -- This makes the separator between the definition and description look a
    -- bit better, instead of it looking like a distracting black line.
    local buf, win = default(contents, syntax, opts)
    local lines = api.nvim_buf_get_lines(buf, 0, -1, false)

    for i, line in ipairs(lines) do
      if vim.startswith(line, '─') and vim.endswith(line, '─') then
        api.nvim_buf_add_highlight(buf, -1, 'TelescopeBorder', i - 1, 0, -1)
      end
    end

    return buf, win
  end
end

-- Floating window borders {{{1
do
  local default = lsp.util.make_floating_popup_options

  lsp.util.make_floating_popup_options = function(width, height, opts)
    local new_opts = vim.tbl_deep_extend('force', opts or {}, {
      border = {
        ' ', -- top left
        ' ', -- top
        ' ', -- top right
        ' ', -- right
        ' ', -- bottom right
        ' ', -- bottom
        ' ', -- bottom left
        ' ', -- left
      },
    })

    return default(width, height, new_opts)
  end
end

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
  update_in_insert = false,
})

-- Signs {{{1
vim.fn.sign_define({
  {
    name = 'DiagnosticSignError',
    text = '▌',
    numhl = 'DiagnosticError',
    texthl = 'DiagnosticError',
  },
  {
    name = 'DiagnosticSignWarn',
    text = '▌',
    numhl = 'DiagnosticWarn',
    texthl = 'DiagnosticWarn',
  },
  {
    name = 'DiagnosticSignHint',
    text = '▌',
    numhl = 'DiagnosticHint',
    texthl = 'DiagnosticHint',
  },
  {
    name = 'DiagnosticSignInfo',
    text = '▌',
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
  local runtime_files = vim.api.nvim_list_runtime_paths()

  table.insert(rpath, 'lua/?.lua')
  table.insert(rpath, 'lua/?/init.lua')

  config.lua_ls.setup({
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
          disable = {
            'missing-fields',
            'duplicate-set-field',
            'undefined-field',
          },
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
  cmd = { 'rust-analyzer' },
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
      lruCapacity = 64,
      completion = {
        postfix = {
          enable = false,
        },
        autoself = {
          enable = false,
        },
      },
    },
  },
})

-- vim: set foldmethod=marker:
