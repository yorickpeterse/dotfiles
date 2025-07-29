local pick = require('mini.pick')
local util = require('dotfiles.util')
local ts = require('dotfiles.mini.pickers.treesitter')
local lsp = require('dotfiles.mini.pickers.lsp')
local api = vim.api
local M = {}

function M.start()
  local bufnr = api.nvim_get_current_buf()
  local ft = api.nvim_get_option_value('ft', { buf = bufnr })

  if util.has_lsp_clients_supporting(bufnr, 'document_symbol') then
    lsp.document_symbols()
    return
  end

  ts.start()
end

return M
