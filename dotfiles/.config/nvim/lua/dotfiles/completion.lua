-- Custom completion for LSP symbols and more, using an omnifunc function.

local lsp = vim.lsp
local api = vim.api
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

-- The minimum word length for it to be included in the buffer completion
-- results.
local min_word_size = 3

-- The name of the buffer-local variable used for keeping track of completion
-- confirmations.
local confirmed_var = 'dotfiles_completion_confirmed'

-- The Vim regex to use for splitting buffer words.
--
-- We only concern ourselves with ASCII words, as I rarely encounter multi-byte
-- characters in e.g. identifiers (or other words I want to complete).
local buffer_word_regex = '[^?a-zA-Z0-9_\\-]\\+'

local function is_confirmed()
  return vim.b[confirmed_var] == true
end

local function set_confirmed()
  vim.b[confirmed_var] = true
end

local function reset_confirmed()
  vim.b[confirmed_var] = false
end

-- Returns a tuple that contains the completion start position and prefix.
local function completion_position()
  local pos = api.nvim_win_get_cursor(0)
  local line = api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, pos[2])
  local start_pos = vim.fn.match(line_to_cursor, '\\k*$') + 1
  local prefix = line_to_cursor:sub(start_pos)

  return { start_pos, prefix }
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

-- Moves the cursor to the given line and column.
local function move_cursor(line, column)
  api.nvim_win_set_cursor(0, { line + 1, column })
end

-- Removes the user provided prefix from the buffer, and resets the cursor to
-- the right place.
local function remove_prefix(start_col, start_line, stop_col, stop_line)
  local buffer = api.nvim_get_current_buf()
  local edit = {
    range = {
      ['start'] = { line = start_line, character = start_col },
      ['end'] = { line = stop_line, character = stop_col }
    },
    newText = ''
  }

  lsp.util.apply_text_edits({ edit }, buffer)
  move_cursor(start_line, start_col)
end

-- Inserts text at the current location.
local function insert_text(text)
  local pos = api.nvim_win_get_cursor(0)
  local line = pos[1] - 1
  local column = pos[2]
  local buffer = api.nvim_get_current_buf()
  local edit = {
    range = {
      ['start'] = { line = line, character = column },
      ['end'] = { line = line, character = column }
    },
    newText = text
  }

  lsp.util.apply_text_edits({ edit }, buffer)
  move_cursor(line, column + #text)
end

-- Inserts the final completion into the buffer.
local function insert_completion(item)
  if item == nil then
    return
  end

  if item.user_data == nil or item.user_data.dotfiles == nil then
    return
  end

  local data = item.user_data.dotfiles
  local pos = api.nvim_win_get_cursor(0)
  local line = pos[1] - 1
  local column = pos[2]

  if data.source == 'lsp' then
    remove_prefix(data.column, data.line, column, line)

    -- When completing an LSP symbol, the text inserted so far is a placeholder.
    -- We need to replace this with the LSP snippet and expand it.
    vim.fn['vsnip#anonymous'](data.expand)

    return
  end

  -- Calculate the start of the column based on the current cursor position, and
  -- the length of the placeholder text.
  local start_column = column - vim.fn.strchars(item.word)

  if start_column < 0 then
    start_column = 0
  end

  remove_prefix(start_column, line, column, line)

  if data.source == 'vsnip' then
    vim.fn['vsnip#anonymous'](data.expand)
    return
  end

  insert_text(item.word)
end

-- Returns all snippets to insert into the completion menu.
local function snippet_completion_items(buffer, column, prefix)
  -- TextEdit lines are 0 based, but nvim starts at 1
  local line = api.nvim_win_get_cursor(0)[1] - 1
  local snippets = {}

  -- When the input is `.|`, where | is the cursor, we don't want to trigger
  -- completion of snippets.
  if prefix == '' then
    return snippets
  end

  for _, source in ipairs(vim.fn['vsnip#source#find'](buffer)) do
    for _, snippet in ipairs(source) do
      for _, snippet_prefix in ipairs(snippet.prefix) do
        if vim.startswith(snippet_prefix, prefix) then
          if #snippet.description > 0 then
            local menu = snippet.description
          else
            local menu = snippet.label
          end

          table.insert(
            snippets,
            {
              word = snippet_prefix,
              abbr = snippet_prefix,
              kind = 'Snippet',
              menu = menu,
              user_data = {
                dotfiles = {
                  expand = vim.fn.join(snippet.body, "\n"),
                  source = 'vsnip'
                }
              }
            }
          )
        end
      end
    end
  end

  -- Sort the snippets alphabetically by their prefixes.
  table.sort(snippets, function(a, b) return a.word < b.word end)

  return snippets
end

-- Returns completion items for all words in the buffers in the current tab.
function buffer_completion_items(_buffer, column, prefix)
  local words = {}

  for _, window in ipairs(api.nvim_tabpage_list_wins(0)) do
    local buffer = api.nvim_win_get_buf(window)
    local lines = vim.fn.join(api.nvim_buf_get_lines(buffer, 0, -1, true))

    for _, word in ipairs(vim.fn.split(lines, buffer_word_regex)) do
      if #word >= min_word_size and vim.startswith(word, prefix) then
        if words[word] then
          local data = words[word].user_data.dotfiles

          data.count = data.count + 1
        else
          words[word] = {
            word = word,
            abbr = word,
            kind = 'Text',
            user_data = {
              dotfiles = {
                source = 'buffer',
                count = 1
              }
            }
          }
        end
      end
    end
  end

  -- If the prefix only occurs once, it means it doesn't occur anywhere but in
  -- the user's input. In this case we don't want to include it.
  if words[prefix] and words[prefix].user_data.dotfiles.count == 1 then
    words[prefix] = nil
  end

  local items = {}

  for _, item in pairs(words) do
    table.insert(items, item)
  end

  table.sort(items, function(a, b) return a.word < b.word end)

  return items
end

-- Shows the completions in the completion menu.
local function show_completions(start_pos, items)
    -- When there's only one candidate, we insert/expand it right away.
    if #items == 1 then
      insert_completion(items[1])
    else
      vim.fn.complete(start_pos, items)
    end
end

-- Performs a fallback completion if a language server client isn't available.
local function fallback_completion(findstart, prefix)
  local start_pos, prefix = unpack(completion_position())
  local bufnr = api.nvim_get_current_buf()
  local items = snippet_completion_items(bufnr, start_pos, prefix)
  local words = buffer_completion_items(bufnr, start_pos, prefix)

  vim.list_extend(items, words)

  -- This is so we can automatically insert and expand the first entry. This
  -- doesn't work reliably when returning the items directly.
  vim.schedule(function() show_completions(start_pos, items) end)

  return -2
end

-- A omnifunc/completefunc function that starts the manual/sync completion of
-- the user's input.
function M.start(findstart, base)
  reset_confirmed()

  local bufnr = api.nvim_get_current_buf()

  -- Don't do anything when there are no clients connected (= no language server
  -- is used).
  if #lsp.buf_get_clients(bufnr) == 0 then
    return fallback_completion(findstart, base)
  end

  local start_pos, prefix = unpack(completion_position())
  local params = lsp.util.make_position_params()
  local items = snippet_completion_items(bufnr, start_pos, prefix)

  lsp.buf_request(
    bufnr,
    'textDocument/completion',
    params,
    function(err, _, result)
      if err or not result then
        show_completions(start_pos, items)
        return
      end

      local lsp_items = vim
        .lsp
        .util
        .text_document_completion_list_to_complete_items(result, prefix)

      -- Now that we have the items, we need to process them so the right text
      -- is inserted when changing the selected entry.
      for _, item in ipairs(lsp_items) do
        -- Keywords are ignored as I find them too distracting.
        if item.kind ~= 'Keyword' then
          local completion = item.user_data.nvim.lsp.completion_item

          -- The text to insert will include the placeholders, which we don't
          -- want. So instead we'll display the filter text, and fall back to
          -- the label.
          item.word = filter_text(completion)

          item.user_data = {
            dotfiles = {
              -- The raw text will be used to properly expand snippets. This is
              -- handled by the complete_done() function.
              expand = text_to_expand(completion),
              source = 'lsp',
              line = completion.textEdit.range.start.line,
              column = completion.textEdit.range.start.character
            }
          }

          table.insert(items, item)
        end
      end

      show_completions(start_pos, items)
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
