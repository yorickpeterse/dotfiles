-- Custom completion for LSP symbols and more, using an omnifunc function.

local lsp = vim.lsp
local api = vim.api
local ui = vim.ui
local util = require('dotfiles.util')
local snippy = require('snippy')
local snippy_shared = require('snippy.shared')
local previewers = require('telescope.previewers')
local actions = require('telescope.actions')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local action_state = require('telescope.actions.state')
local tele_conf = require('telescope.config')
local entry_display = require('telescope.pickers.entry_display')
local fn = vim.fn
local M = {}

-- This disables NeoVim's built-in snippet parser, just to make sure it never
-- messes with our own.
lsp.util.parse_snippet = function(input)
  return input
end

-- The minimum word length for it to be included in the buffer completion
-- results.
local min_word_size = 3

-- The Vim regex to use for splitting buffer words.
--
-- We only concern ourselves with ASCII words, as I rarely encounter multi-byte
-- characters in e.g. identifiers (or other words I want to complete).
local buffer_word_regex = '[^?a-zA-Z0-9_]\\+'

local kinds = lsp.protocol.CompletionItemKind
local text_kind = kinds[kinds.Text]
local snippet_kind = kinds[kinds.Snippet]
local keyword_kind = kinds[kinds.Keyword]
local module_kind = kinds[kinds.Module]

local ignored_kinds = {
  -- Keyword completion isn't really useful.
  [kinds[kinds.Keyword]] = true,

  -- Not sure what these are meant for, but rust-analyzer sometimes produces
  -- these for nightly-only macros.
  [kinds[kinds.Reference]] = true,
}

local function completion_position()
  local line, col = unpack(api.nvim_win_get_cursor(0))
  local line_text = api.nvim_get_current_line()
  local line_to_cursor = line_text:sub(1, col)
  local column = fn.match(line_to_cursor, '\\k*$')
  local prefix = line_to_cursor:sub(column + 1)

  return { line, column, prefix }
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

-- Returns the text to use for filtering entries.
local function filter_text(item)
  if item.filterText then
    return item.filterText
  elseif item.label then
    return item.label
  else
    return item.insertText
  end
end

-- Given a completion item for a snippet and text, returns the snippet's item.
local function snippet_from_binary_completion(items)
  local first = items[1]
  local second = items[2]

  if first.filter ~= second.filter then
    return
  end

  if first.kind == snippet_kind and second.kind == text_kind then
    return first
  end

  if first.kind == text_kind and second.kind == snippet_kind then
    return second
  end
end

local function remove_text(text, line, column)
  local bufnr = api.nvim_get_current_buf()

  api.nvim_buf_set_text(bufnr, line - 1, column, line - 1, column + #text, {})
  api.nvim_win_set_cursor(0, { line, column })
end

-- Returns all the snippets for the current buffer.
local function available_snippets(buffer)
  snippy.read_snippets()

  local snippets = {}

  for _, scope in ipairs(snippy_shared.get_scopes()) do
    if scope and snippy.snippets[scope] then
      for _, snippet in pairs(snippy.snippets[scope]) do
        table.insert(snippets, snippet)
      end
    end
  end

  return snippets
end

-- Inserts the final completion into the buffer.
local function insert_completion(prefix, item)
  if item.source == 'lsp' or item.source == 'snippet' then
    snippy.expand_snippet(item.insert, prefix)
  else
    remove_text(prefix, item.line, item.column)
    api.nvim_put({ item.insert }, '', false, true)
  end
end

-- Returns all snippets to insert into the completion menu.
local function snippet_completion_items(buffer, column, prefix)
  local line = api.nvim_win_get_cursor(0)[1]
  local snippets = {}
  local before_prefix = (
    api.nvim_buf_get_lines(buffer, line - 1, line, false)[1] or ''
  ):sub(column, column)

  -- Only trigger snippet completion if we have a search term, and the term is
  -- either at the start of the line or preceded by whitespace.
  if
    (before_prefix ~= '' and not before_prefix:match('%s')) or prefix == ''
  then
    return snippets
  end

  for _, snippet in ipairs(available_snippets(buffer)) do
    if vim.startswith(snippet.prefix, prefix) then
      table.insert(snippets, {
        filter = snippet.prefix,
        label = snippet.prefix,
        insert = snippet,
        kind = snippet_kind,
        docs = {
          kind = 'plain',
          value = snippet.description,
        },
        source = 'snippet',
        line = line,
        column = column,
      })
    end
  end

  return snippets
end

-- Returns completion items for all words in the buffers in the current tab.
function buffer_completion_items(column, prefix)
  local buffers = {}
  local processed = {}

  if prefix == '' then
    return {}
  end

  for _, window in ipairs(api.nvim_tabpage_list_wins(0)) do
    local buffer = api.nvim_win_get_buf(window)

    if processed[buffer] == nil and api.nvim_buf_is_loaded(buffer) then
      table.insert(buffers, buffer)
      processed[buffer] = true
    end
  end

  local words = {}
  local line = api.nvim_win_get_cursor(0)[1]

  for _, buffer in ipairs(buffers) do
    local lines = fn.join(api.nvim_buf_get_lines(buffer, 0, -1, true))

    for _, word in ipairs(fn.split(lines, buffer_word_regex)) do
      if #word >= min_word_size and vim.startswith(word, prefix) then
        if words[word] then
          local item = words[word]

          item.count = item.count + 1
        else
          words[word] = {
            filter = word,
            label = word,
            insert = word,
            kind = text_kind,
            source = 'buffer',
            count = 1,
            line = line,
            column = column,
          }
        end
      end
    end
  end

  -- If the prefix only occurs once, it means it doesn't occur anywhere but in
  -- the user's input. In this case we don't want to include it.
  if words[prefix] and words[prefix].count == 1 then
    words[prefix] = nil
  end

  local items = {}

  for _, item in pairs(words) do
    table.insert(items, item)
  end

  return items
end

local function show_picker(prefix, items)
  local hl = 'Normal:Pmenu,EndOfBuffer:Pmenu'
  local opts = {
    layout_strategy = 'completion',
    default_text = #prefix > 0 and prefix or '',
    prompt_prefix = '',
    entry_prefix = '',
    multi_icon = '',
    selection_caret = '',
    show_line = false,
    prompt_title = false,
    results_title = false,
    preview = { hide_on_startup = true },
  }

  local previewer = previewers.new_buffer_previewer({
    title = 'Documentation',
    define_preview = function(self, entry, status)
      local docs = entry.value.docs

      api.nvim_win_set_option(self.state.winid, 'winhl', hl)

      if docs and docs.value then
        local lines = vim.split(docs.value, '\n', { trimempty = true })

        if docs.kind == 'markdown' then
          api.nvim_buf_set_option(self.state.bufnr, 'ft', 'markdown')
          api.nvim_win_set_option(self.state.winid, 'conceallevel', 2)
          api.nvim_win_set_option(self.state.winid, 'wrap', true)
          api.nvim_win_set_option(self.state.winid, 'linebreak', true)
          lsp.util.stylize_markdown(self.state.bufnr, lines, {})
        else
          api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        end
      end
    end,
  })

  local name_size = 0

  for _, item in pairs(items) do
    local size = api.nvim_strwidth(item.label)

    if size > name_size then
      name_size = size
    end
  end

  name_size = name_size + 2

  if name_size > 40 then
    name_size = 40
  end

  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = name_size },
      { remaining = true },
    },
  })

  local finder = finders.new_table({
    results = items,
    entry_maker = function(item)
      return {
        value = item,
        display = function(entry)
          return displayer({
            entry.value.label,
            { entry.value.detail or '', 'TelescopeResultsComment' },
          })
        end,
        ordinal = item.filter,
      }
    end,
  })

  -- Enter insert mode again when the completion window is dismissed. For some
  -- reason this function is called twice when closing, so we use a flag to
  -- prevent running the code twice.
  local closed = false

  finder.close = function()
    if closed then
      return
    end

    closed = true

    -- Enter insert mode again _after_ the last typed/inserted character.
    api.nvim_feedkeys('a', 'n', true)
  end

  local picker = pickers.new(opts, {
    finder = finder,
    previewer = previewer,
    sorter = tele_conf.values.generic_sorter(),
    attach_mappings = function(bufnr, map)
      map('i', '<Esc>', actions.close)
      map('i', '<C-{>', actions.close)
      actions.select_default:replace(function()
        actions.close(bufnr)

        local entry = action_state.get_selected_entry()

        if entry then
          insert_completion(prefix, entry.value)
        end
      end)

      return true
    end,
  })

  local create_layout = picker.create_layout

  picker.create_layout = function(self)
    local layout = create_layout(self)
    local mount = layout.mount
    local update = layout.update

    layout.mount = function(self)
      mount(self)
      api.nvim_win_set_option(self.prompt.winid, 'winhl', hl)
      api.nvim_win_set_option(self.results.winid, 'winhl', hl)
    end

    return layout
  end

  picker:find()
end

-- Shows the completions in the completion menu.
local function show_completions(prefix, items)
  if #items == 0 then
    return
  end

  -- When there's only one candidate, we insert/expand it right away.
  if #items == 1 then
    insert_completion(prefix, items[1])
    return
  end

  -- Sort the initial list in alphabetical order.
  table.sort(items, function(a, b)
    return a.filter < b.filter
  end)

  -- It's possible for there to be only two entries, one of which is a snippet,
  -- and one of which is text. If both have the same word value, we want to
  -- automatically insert a snippet. This way I can have a snippet called "def",
  -- while "def" also exists as a keyword in the buffer, and automatically
  -- complete the snippet.
  if #items == 2 then
    local snippet = snippet_from_binary_completion(items)

    if snippet then
      insert_completion(prefix, snippet)
      return
    end
  end

  -- If multiple matches exist but one of them matches the prefix exactly,
  -- favour the one that matches exactly. This way if you type `x.map[TAB]` and
  -- the candidates are `map` and `map_foo`, then it picks `map`, based on the
  -- assumption that's probably what you wanted.
  for _, item in ipairs(items) do
    if item.filter == prefix then
      insert_completion(prefix, item)
      return
    end
  end

  -- If we only have a few candidates, and our prefix is close enough to of one
  -- of the items, we insert that item.
  if #items <= 5 then
    local close = {}

    for _, item in ipairs(items) do
      if
        -- If the canditates list includes a module reference and a bunch of
        -- others (e.g. variables), in 9 out of 10 cases I don't care about the
        -- module reference, so we ignore it here to make completing e.g.
        -- variables easier.
        item.kind ~= module_kind
        and (#item.filter == 2 or (#prefix / #item.filter) * 100 >= 65)
      then
        table.insert(close, item)
      end
    end

    if #close == 1 then
      insert_completion(prefix, close[1])
      return
    end
  end

  show_picker(prefix, items)
end

-- Performs a fallback completion if a language server client isn't available.
local function fallback_completion(column, prefix)
  local bufnr = api.nvim_get_current_buf()
  local items = snippet_completion_items(bufnr, column, prefix)
  local words = buffer_completion_items(column, prefix)

  vim.list_extend(items, words)
  show_completions(prefix, items)
end

function M.start()
  local line, column, prefix = unpack(completion_position())
  local bufnr = api.nvim_get_current_buf()

  if not util.has_lsp_clients_supporting(bufnr, 'completion') then
    return fallback_completion(column, prefix)
  end

  local params = lsp.util.make_position_params()
  local items = snippet_completion_items(bufnr, column, prefix)

  lsp.buf_request(
    bufnr,
    'textDocument/completion',
    params,
    function(err, result)
      if err or not result then
        show_completions(prefix, items)
        return
      end

      local lsp_items =
        lsp.util.text_document_completion_list_to_complete_items(result, prefix)

      -- Now that we have the items, we need to process them so the right text
      -- is inserted when changing the selected entry.
      for _, item in ipairs(lsp_items) do
        if not ignored_kinds[item.kind] then
          local completion = item.user_data.nvim.lsp.completion_item
          local filter = filter_text(completion)

          table.insert(items, {
            filter = filter,
            label = filter,
            insert = text_to_expand(completion),
            kind = kinds[completion.kind],
            docs = completion.documentation,
            detail = completion.detail,
            source = 'lsp',
            line = line,
            column = column,
          })
        end
      end

      show_completions(prefix, items)
    end
  )
end

return M
