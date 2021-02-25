-- Custom completion for LSP symbols and more, using an omnifunc function.

local lsp = vim.lsp
local api = vim.api
local log = require('vim.lsp.log')
local M = {}

-- This disables NeoVim's built-in snippet parser, just to make sure it never
-- messes with our own.
lsp.util.parse_snippet = function(input)
  return input
end

-- (Neo)Vim doesn't provide an easy way to distinguish between text being
-- inserted because it simply was the first entry (when using
-- `completeopt=menu`), or because it was explicitly confirmed.
--
-- Tracking the state here ensures we only confirm a completion (and thus
-- expand a snippet) when the user explicitly confirmed the completion.
local confirmed = false

-- The time (in milliseconds) to wait for a language server to produce results.
local completion_timeout = 4000

-- The name of the buffer-local variable used for keeping track of completion
-- confirmations.
local confirmed_var = 'dotfiles_completion_confirmed'

local function is_confirmed()
  return vim.b[confirmed_var] == true
end

local function set_confirmed()
  vim.b[confirmed_var] = true
end

local function reset_confirmed()
  vim.b[confirmed_var] = false
end

-- Returns the text (which may include snippets) to expand upon confirming a
-- completion.
local function text_to_expand(item)
  if item.textEdit ~= nil and item.textEdit.newText ~= nil then
    return item.textEdit.newText
  elseif item.insertText ~= nil then
    return item.insertText
  else
    return item.label
  end
end

-- Determines what text to initially insert when switching between completion
-- candidates.
local function filter_text(item)
  if item.filterText ~= nil then
    return item.filterText
  else
    return item.label
  end
end

-- Inserts the final completion into the buffer.
--
-- Any LSP snippets included are expanded.
local function insert_completion(item)
  if item == nil then
    return
  end

  if item.user_data == nil or item.user_data.nvim == nil then
    return
  end

  local data = item.user_data.nvim.lsp.completion_item
  local snippet = data.snippet
  local bufnr = api.nvim_get_current_buf()
  local win = api.nvim_get_current_win()
  local curr_line, curr_col = unpack(api.nvim_win_get_cursor(0))
  local start_line = data.textEdit.range.start.line
  local start_col = data.textEdit.range.start.character
  local edit = {
    range = {
      -- This is the start of the completion range, provided by the language
      -- server. The range starts before the inserted text.
      ['start'] = {
        line = start_line,
        character = start_col
      },
      ['end'] = {
        line = curr_line - 1,
        character = curr_col
      }
    },
    newText = ''
  }

  -- This will remove the text that was inserted upon confirming the completion.
  lsp.util.apply_text_edits({ edit }, bufnr)

  -- Move the cursor to the start of the text we just removed, otherwise the
  -- snippet gets inserted in the wrong location.
  api.nvim_win_set_cursor(win, { start_line + 1, start_col })

  -- Now we can expand the snippet and insert it.
  vim.fn['vsnip#anonymous'](snippet)
end

-- A omnifunc/completefunc function that starts the manual/sync completion of
-- the user's input.
function M.start(findstart, base)
  reset_confirmed()

  local bufnr = api.nvim_get_current_buf()

  -- Don't do anything when there are no clients connected (= no language server
  -- is used).
  if #lsp.buf_get_clients(bufnr) == 0 then
    -- TODO: buffer+snippet fallback
    return -1
  end

  local pos = api.nvim_win_get_cursor(0)
  local line = api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, pos[2])
  local match = vim.fn.match(line_to_cursor, '\\k*$') + 1
  local prefix = line_to_cursor:sub(match)
  local params = lsp.util.make_position_params()

  lsp.buf_request(
    bufnr,
    'textDocument/completion',
    params,
    function(err, _, result)
      if err or not result then return end

      local items = vim
        .lsp
        .util
        .text_document_completion_list_to_complete_items(result, prefix)

      -- Now that we have the items, we need to process them so the right text
      -- is inserted when changing the selected entry.
      for _, item in ipairs(items) do
        local completion = item.user_data.nvim.lsp.completion_item

        -- The text to insert will include the placeholders, which we don't
        -- want. So instead we'll display the filter text, and fall back to the
        -- label.
        item.word = filter_text(completion)

        -- The raw text will be used to properly expand snippets. This is
        -- handled by the complete_done() function.
        completion.snippet = text_to_expand(completion)
      end

      -- TODO: add snippets
      -- for _, item in ipairs(vim.fn['vsnip#get_complete_items'](bufnr)) do
      --   print(vim.inspect(item))
      --   table.insert(items, item)
      -- end

      -- When there's only one candidate, we insert/expand it right away.
      if #items == 1 then
        insert_completion(items[1])
      else
        vim.fn.complete(match, items)
      end
    end
  )

  return -2
end

-- Confirms a completion.
function M.confirm()
  if vim.fn.pumvisible() == 1 then
    set_confirmed()
  end

  return api.nvim_replace_termcodes('<C-y>', true, true, true)
end

-- Expands a completion.
function M.done()
  local item = vim.v.completed_item

  if is_confirmed() then
    reset_confirmed()
  else
    return
  end

  return insert_completion(item)
end

return M
