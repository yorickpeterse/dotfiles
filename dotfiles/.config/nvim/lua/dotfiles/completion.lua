-- Custom completion for LSP symbols and more, using an omnifunc function.

local lsp = vim.lsp
local api = vim.api
local util = require('dotfiles.util')
local lsnip = require('luasnip')
local lsnip_util = require('luasnip.util.util')
local fn = vim.fn
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
local buffer_word_regex = '[^?a-zA-Z0-9_]\\+'

local kinds = lsp.protocol.CompletionItemKind
local text_kind = kinds[kinds.Text]
local snippet_kind = kinds[kinds.Snippet]
local keyword_kind = kinds[kinds.Keyword]

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
  local start_pos = fn.match(line_to_cursor, '\\k*$') + 1
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
  return item.insertText or item.filterText or item.label
end

-- Given a completion item for a snippet and text, returns the snippet's item.
local function snippet_from_binary_completion(items)
  local first = items[1]
  local second = items[2]

  if first.word ~= second.word then
    return
  end

  if first.kind == snippet_kind and second.kind == text_kind then
    return first
  end

  if first.kind == text_kind and second.kind == snippet_kind then
    return second
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
      ['end'] = { line = stop_line, character = stop_col },
    },
    newText = '',
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
      ['end'] = { line = line, character = column },
    },
    newText = text,
  }

  lsp.util.apply_text_edits({ edit }, buffer)
  move_cursor(line, column + #text)
end

-- Returns all the snippets for the current buffer.
local function available_snippets(buffer)
  local buf_ft = api.nvim_buf_get_option(buffer, 'ft')
  local avail = {}

  for _, ft in ipairs(lsnip_util.get_snippet_filetypes(buf_ft)) do
    if lsnip.snippets[ft] then
      for index, snippet in pairs(lsnip.snippets[ft]) do
        if not snippet.hidden then
          table.insert(avail, {
            prefix = snippet.trigger,
            description = snippet.dscr[1],
            index = index,
            ft = ft,
          })
        end
      end
    end
  end

  return avail
end

-- Inserts the final completion into the buffer.
local function insert_completion(item)
  if item.user_data == nil or item.user_data.dotfiles == nil then
    return
  end

  local data = item.user_data.dotfiles
  local pos = api.nvim_win_get_cursor(0)
  local line = pos[1] - 1
  local column = pos[2]

  remove_prefix(data.column, data.line, column, line)

  if data.source == 'lsp' then
    lsnip.lsp_expand(data.expand)
  elseif data.source == 'snippet' then
    local snippet = lsnip.snippets[data.expand.ft][data.expand.index]

    -- LuaSnip requires the trigger text to be present, so we must insert it
    -- first.
    insert_text(snippet.trigger)
    snippet:trigger_expand(
      lsnip.session.current_nodes[api.nvim_get_current_buf()]
    )
  else
    insert_text(item.word)
  end
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

  for _, snippet in ipairs(available_snippets(buffer)) do
    if vim.startswith(snippet.prefix, prefix) then
      table.insert(snippets, {
        word = snippet.prefix,
        abbr = snippet.prefix,
        kind = snippet_kind,
        menu = snippet.description,
        dup = 1,
        user_data = {
          dotfiles = {
            expand = snippet,
            source = 'snippet',
            line = line,
            column = column - 1,
          },
        },
      })
    end
  end

  -- Sort the snippets alphabetically by their prefixes.
  table.sort(snippets, function(a, b)
    return a.word < b.word
  end)

  return snippets
end

-- Returns completion items for all words in the buffers in the current tab.
function buffer_completion_items(column, prefix)
  local buffers = {}
  local processed = {}

  for _, window in ipairs(api.nvim_tabpage_list_wins(0)) do
    local buffer = api.nvim_win_get_buf(window)

    if processed[buffer] == nil and api.nvim_buf_is_loaded(buffer) then
      table.insert(buffers, buffer)
      processed[buffer] = true
    end
  end

  local words = {}
  local line = api.nvim_win_get_cursor(0)[1] - 1

  for _, buffer in ipairs(buffers) do
    local lines = fn.join(api.nvim_buf_get_lines(buffer, 0, -1, true))

    for _, word in ipairs(fn.split(lines, buffer_word_regex)) do
      if #word >= min_word_size and vim.startswith(word, prefix) then
        if words[word] then
          local data = words[word].user_data.dotfiles

          data.count = data.count + 1
        else
          words[word] = {
            word = word,
            abbr = word,
            kind = text_kind,
            dup = 1,
            user_data = {
              dotfiles = {
                source = 'buffer',
                count = 1,
                line = line,
                column = column - 1,
              },
            },
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

  table.sort(items, function(a, b)
    return a.word < b.word
  end)

  return items
end

-- Shows the completions in the completion menu.
local function show_completions(start_pos, items)
  -- When there's only one candidate, we insert/expand it right away.
  if #items == 1 then
    insert_completion(items[1])
    return
  end

  -- It's possible for there to be only two entries, one of which is a snippet,
  -- and one of which is text. If both have the same word value, we want to
  -- automatically insert a snippet. This way I can have a snippet called "def",
  -- while "def" also exists as a keyword in the buffer, and automatically
  -- complete the snippet.
  if #items == 2 then
    local snippet = snippet_from_binary_completion(items)

    if snippet then
      insert_completion(snippet)
      return
    end
  end

  fn.complete(start_pos, items)
end

-- Performs a fallback completion if a language server client isn't available.
local function fallback_completion(prefix)
  local start_pos, prefix = unpack(completion_position())
  local bufnr = api.nvim_get_current_buf()
  local items = snippet_completion_items(bufnr, start_pos, prefix)
  local words = buffer_completion_items(start_pos, prefix)

  vim.list_extend(items, words)

  -- This is so we can automatically insert and expand the first entry. This
  -- doesn't work reliably when returning the items directly.
  vim.schedule(function()
    show_completions(start_pos, items)
  end)

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
    return fallback_completion(base)
  end

  local comp_line = api.nvim_win_get_cursor(0)[1]
  local start_pos, prefix = unpack(completion_position())
  local params = lsp.util.make_position_params()
  local items = snippet_completion_items(bufnr, start_pos, prefix)

  lsp.buf_request(
    bufnr,
    'textDocument/completion',
    params,
    function(err, result)
      if err or not result then
        show_completions(start_pos, items)
        return
      end

      local lsp_items =
        vim.lsp.util.text_document_completion_list_to_complete_items(
          result,
          prefix
        )

      -- Now that we have the items, we need to process them so the right text
      -- is inserted when changing the selected entry.
      for _, item in ipairs(lsp_items) do
        -- Keywords are ignored as I find them too distracting.
        if item.kind ~= keyword_kind then
          local completion = item.user_data.nvim.lsp.completion_item

          -- The text to insert will include the placeholders, which we don't
          -- want. So instead we'll display the filter text, and fall back to
          -- the label.
          item.word = filter_text(completion)

          item.user_data = {
            dotfiles = {
              -- The raw text will be used to properly expand snippets. This
              -- is handled by the complete_done() function.
              expand = text_to_expand(completion),
              source = 'lsp',
              line = comp_line - 1,
              column = start_pos - 1,
            },
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
  if fn.pumvisible() == 1 then
    set_confirmed()
  end

  return util.keycode('<C-y>')
end

-- Expands a completion.
function M.done()
  local item = vim.v.completed_item

  if is_confirmed() then
    reset_confirmed()
  else
    return
  end

  if item then
    return insert_completion(item)
  end
end

return M
