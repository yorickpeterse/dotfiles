local pickers = require('telescope.pickers')
local entry_display = require('telescope.pickers.entry_display')
local finders = require('telescope.finders')
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

local function lsp_symbols_entry_maker()
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = 40 },
      { remaining = true },
    },
  })

  return function(entry)
    return {
      value = entry,
      ordinal = entry.text,
      display = function(entry)
        return displayer({
          entry.symbol_name,
          { entry.symbol_scope, 'TelescopeResultsComment' },
        })
      end,
      filename = entry.filename,
      lnum = entry.lnum,
      col = entry.col,
      symbol_name = entry.text,
      symbol_scope = entry.scope or '',
      start = entry.start,
      finish = entry.finish,
    }
  end
end

-- A picker that shows LSP document symbols along with their surrounding scope.
function M.lsp_document_symbols(bufnr, opts)
  opts = opts or {}

  vim.lsp.buf_request_all(
    bufnr,
    'textDocument/documentSymbol',
    { textDocument = vim.lsp.util.make_text_document_params() },
    function(response)
      local locations = {}

      for _, result in pairs(response) do
        if result.result then
          for _, symbol in ipairs(flatten_document_symbols(result.result, {})) do
            table.insert(locations, {
              bufnr = bufnr,
              filename = vim.api.nvim_buf_get_name(bufnr),
              lnum = symbol.selectionRange.start.line + 1,
              col = symbol.selectionRange.start.character + 1,
              kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown',
              text = symbol.name,
              scope = vim.fn.join(symbol.scope, '/'),
              start = symbol.selectionRange.start.line + 1,
              finish = symbol.selectionRange['end'].line + 1,
            })
          end
        end
      end

      if opts.symbols then
        locations = vim
          .iter(locations)
          :filter(function(item)
            if
              item.kind == 'Constant'
              and opts.ignore_scoped_constants
              and #item.scope > 0
            then
              return false
            end

            return opts.symbols[item.kind] == true
          end)
          :totable()
      end

      if not locations or #locations == 0 then
        return
      end

      pickers
        .new(opts, {
          prompt_title = 'Document symbols',
          finder = finders.new_table({
            results = locations,
            entry_maker = lsp_symbols_entry_maker(),
          }),
          previewer = conf.qflist_previewer(opts),
          sorter = conf.generic_sorter(opts),
        })
        :find()
    end
  )
end

return M
