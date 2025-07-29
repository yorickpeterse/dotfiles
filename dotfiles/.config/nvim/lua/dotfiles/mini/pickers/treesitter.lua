local pick = require('mini.pick')
local show = require('dotfiles.mini.show')
local api = vim.api
local ts = vim.treesitter
local M = {}

local KINDS = {
  constant = 'Constant',
  type = 'Class',
  enum = 'Class',
  field = 'Field',
  ['function'] = 'Function',
  macro = 'Macro',
  method = 'Function',
  namespace = 'Namespace',
}

local function find_parent(node, scopes)
  local current = node:parent()

  while current do
    if scopes[current:id()] then
      break
    else
      current = current:parent()
    end
  end

  return current
end

function M.start()
  local buf = api.nvim_get_current_buf()
  local has_parser, parser = pcall(ts.get_parser, buf)

  if not has_parser or parser == nil then
    return
  end

  local query = ts.query.get(parser:lang(), 'locals')

  if not query then
    return
  end

  local items = {}
  local scopes = {}

  for _, tree in ipairs(parser:trees()) do
    for id, node, meta in query:iter_captures(tree:root(), buf) do
      local name = query.captures[id]

      if name == 'local.scope' then
        scopes[node:id()] = true
      end
    end
  end

  for _, tree in ipairs(parser:trees()) do
    for id, node, meta in query:iter_captures(tree:root(), buf) do
      local name = query.captures[id]
      local text = ts.get_node_text(node, buf)
      local lnum, col, end_lnum, end_col = node:range()
      local kind = KINDS[name:match('^local%.definition%.(.*)$')]

      -- The type definition node is the name of some scope, so we need to find
      -- that scope first, then find the parent of that scope.
      local parent = find_parent(node, scopes)
      local scope = nil

      if parent then
        local root = find_parent(parent, scopes)

        if root then
          parent = root
        end
      end

      if parent then
        scope = vim.split(ts.get_node_text(parent, buf), '\n')[1]

        -- This gets rid of opening curly braces on the first line. This isn't
        -- ideal, but there's no easier way to get the "name" of a scope without
        -- that scope also introducing a new symbol (i.e. there's no capture
        -- group for just a scope name, only for symbol definitions).
        if vim.endswith(scope, '{') then
          scope = scope:gsub('%s{$', '')
        end
      end

      lnum, col, end_lnum, end_col =
        lnum + 1, col + 1, end_lnum + 1, end_col + 1

      local key = text
        .. tostring(lnum)
        .. tostring(col)
        .. tostring(end_lnum)
        .. tostring(end_col)

      if kind and not items[key] then
        items[key] = {
          parent = { text = scope },
          text = text,
          kind = kind,
          buf = buf,
          lnum = lnum,
          col = col,
          end_lnum = end_lnum,
          end_col = end_col,
        }
      end
    end
  end

  local sorted = vim.tbl_values(items)

  table.sort(sorted, function(a, b)
    return a.text < b.text
  end)

  pick.start({
    source = {
      items = sorted,
      name = 'Tree-sitter',
      show = show.scoped_symbols,
    },
  })
end

return M
