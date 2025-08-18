local pick = require('mini.pick')
local ts = require('dotfiles.mini.pickers.treesitter')
local show = require('dotfiles.mini.show')
local api = vim.api
local lsp = vim.lsp
local M = {}

local INCLUDE = {
  ['Class'] = true,
  ['Constant'] = true,
  ['Constructor'] = true,
  ['Enum'] = true,
  ['EnumMember'] = true,
  ['Field'] = true,
  ['Function'] = true,
  ['Interface'] = true,
  ['Method'] = true,
  ['Module'] = true,
  ['Namespace'] = true,
  ['Package'] = true,
  ['Property'] = true,
  ['Struct'] = true,
  ['Trait'] = true,
}

local function flatten(symbols, scope)
  local items = {}

  for _, symbol in ipairs(symbols) do
    symbol.scope = scope

    table.insert(items, symbol)

    if symbol.children then
      local new_scope = vim.deepcopy(scope)

      table.insert(new_scope, symbol.name)

      for _, item in ipairs(flatten(symbol.children, new_scope)) do
        table.insert(items, item)
      end
    end
  end

  return items
end

function M.document_symbols()
  local buf = api.nvim_get_current_buf()
  local pars = lsp.util.make_position_params(0, 'utf-8')

  lsp.buf_request(
    buf,
    'textDocument/documentSymbol',
    pars,
    function(err, result)
      if err or not result then
        return
      end

      local items = {}

      for _, sym in ipairs(flatten(result, {})) do
        local loc = sym.selectionRange
        local kind = lsp.protocol.SymbolKind[sym.kind]

        if INCLUDE[kind] then
          table.insert(items, {
            parent = { text = table.concat(sym.scope, ' / ') },
            text = sym.name,
            kind = kind,
            buf = buf,
            lnum = loc.start.line + 1,
            col = loc.start.character + 1,
            end_lnum = loc['end'].line + 1,
            end_col = loc['end'].character + 1,
          })
        end
      end

      table.sort(items, function(a, b)
        return a.text < b.text
      end)

      pick.start({
        source = {
          items = items,
          name = 'Document symbols',
          show = show.scoped_symbols,
        },
      })
    end
  )
end

return M
