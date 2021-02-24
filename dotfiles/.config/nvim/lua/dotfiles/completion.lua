local lsp = vim.lsp
local api = vim.api

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

-- A omnifunc/completefunc function that starts the manual/sync completion of
-- the user's input.
function _G.dotfiles_complete_start(findstart, base)
  local bufnr = api.nvim_get_current_buf()

  -- Don't do anything when there are no clients connected (= no language server
  -- is used).
  if #lsp.buf_get_clients(bufnr) == 0 then
    return
  end

  if findstart == 1 then
    local pos = api.nvim_win_get_cursor(0)
    local line = api.nvim_get_current_line()
    local line_to_cursor = line:sub(1, pos[2])

    return vim.fn.match(line_to_cursor, '\\k*$')
  end

  local params = lsp.util.make_position_params()
  local result =
    lsp.buf_request_sync(bufnr, 'textDocument/completion', params, 4000)

  local items = {}

  if result then
    for _, item in ipairs(result) do
      if not item.err then
        local matches = vim
          .lsp
          .util
          .text_document_completion_list_to_complete_items(item.result, base)

        vim.list_extend(items, matches)
      end
    end
  end

  -- Now that we have the items, we need to process them so the right text is
  -- inserted when changing the selected entry.
  for _, item in ipairs(items) do
    local completion = item.user_data.nvim.lsp.completion_item

    -- The text to insert will include the placeholders, which we don't want. So
    -- instead we'll display the filter text, and fall back to the label.
    item.word = filter_text(completion)

    -- The raw text will be used to properly expand snippets. This is handled
    -- by the complete_done() function.
    completion.snippet = text_to_expand(completion)
  end

  -- Now we can sort the entries alphabetically
  table.sort(items, function(a, b)
    return a.word < b.word
  end)

  return items
end

-- Function to be called by the CompleteDone event.
--
-- This function will expand the inserted text using any snippets provided by
-- the language server.
function _G.dotfiles_complete_done()
  local item = api.nvim_get_vvar('completed_item')

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
