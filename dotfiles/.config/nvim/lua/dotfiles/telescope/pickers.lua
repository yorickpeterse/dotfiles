local pickers = require('telescope.pickers')
local entry_display = require('telescope.pickers.entry_display')
local finders = require('telescope.finders')
local utils = require('telescope.utils')
local conf = require('telescope.config').values
local M = {}

local function flatten_document_symbols(symbols, scope)
  local items = {}

  for _, symbol in ipairs(symbols) do
    symbol.scope = scope

    table.insert(items, symbol)

    if symbol.children then
      local new_scope = vim.deepcopy(scope)

      table.insert(new_scope, symbol.name)

      for _, item in
        ipairs(flatten_document_symbols(symbol.children, new_scope))
      do
        table.insert(items, item)
      end
    end
  end

  return items
end

local function lsp_symbol_to_location(bufnr, symbol)
  return {
    bufnr = bufnr,
    filename = vim.api.nvim_buf_get_name(bufnr),
    lnum = symbol.selectionRange.start.line + 1,
    col = symbol.selectionRange.start.character + 1,
    kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown',
    text = symbol.name,
    scope = vim.fn.join(symbol.scope, '/'),
  }
end

local function lsp_symbols_entry_maker(opts)
  opts = opts or {}

  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local displayer = entry_display.create({
    separator = ' ',
    hl_chars = { ['['] = 'TelescopeBorder', [']'] = 'TelescopeBorder' },
    items = {
      { width = opts.symbol_width or 50 },
      { width = opts.symbol_type_width or 10 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.symbol_name,
      entry.symbol_type:lower(),
      { entry.symbol_scope, 'TelescopeResultsComment' },
    })
  end

  return function(entry)
    local ordinal = entry.text .. ' ' .. entry.scope

    return {
      valid = true,
      value = entry,
      ordinal = ordinal,
      display = make_display,
      filename = entry.filename,
      lnum = entry.lnum,
      col = entry.col,
      symbol_name = entry.text,
      symbol_type = entry.kind,
      symbol_scope = entry.scope or '',
      start = entry.start,
      finish = entry.finish,
    }
  end
end

-- A picker that shows LSP document symbols along with their surrounding scope.
function M.lsp_document_symbols(opts)
  opts = opts or {}

  local bufnr = vim.api.nvim_get_current_buf()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }

  vim.lsp.buf_request_all(
    bufnr,
    'textDocument/documentSymbol',
    params,
    function(response)
      local locations = {}

      for _, result in pairs(response) do
        if result.result then
          for _, symbol in ipairs(flatten_document_symbols(result.result, {})) do
            table.insert(locations, lsp_symbol_to_location(bufnr, symbol))
          end
        end
      end

      locations = utils.filter_symbols(locations, opts)

      if not locations or #locations == 0 then
        return
      end

      pickers.new(opts, {
        prompt_title = 'Document symbols',
        finder = finders.new_table({
          results = locations,
          entry_maker = lsp_symbols_entry_maker(opts),
        }),
        previewer = conf.qflist_previewer(opts),
        sorter = conf.generic_sorter(opts),
      }):find()
    end
  )
end

return M
