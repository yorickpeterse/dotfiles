local lsp = vim.lsp
local api = vim.api
local ui = vim.ui
local util = require('dotfiles.util')
local snippet = require('dotfiles.snippet')
local fn = vim.fn
local M = {}

local namespace = api.nvim_create_namespace('dotfiles_completion')
local augroup =
  api.nvim_create_augroup('dotfiles_completion_menu', { clear = true })

-- The minimum word length for it to be included in the buffer completion
-- results.
local min_word_size = 3

-- The Vim regex to use for splitting buffer words.
--
-- We only concern ourselves with ASCII words, as I rarely encounter multi-byte
-- characters in e.g. identifiers (or other words I want to complete).
local buffer_word_regex = '[^?a-zA-Z0-9_]\\+'

local kinds = lsp.protocol.CompletionItemKind
local text_kind = kinds.Text
local snippet_kind = kinds.Snippet
local module_kind = kinds.Module
local variable_kind = kinds.Variable
local ignored_kinds = {
  -- Keyword completion isn't really useful.
  [kinds.Keyword] = true,

  -- Not sure what these are meant for, but rust-analyzer sometimes produces
  -- these for nightly-only macros.
  [kinds.Reference] = true,
}

-- The number of columns of the code completion menu.
local menu_columns = 50

-- The maximum number of rows to display in the results menu.
local menu_rows = 10

local menu_below_anchor = 'NW'
local menu_above_anchor = 'SW'
local menu_status_col = ' %-2{min([9, v:lnum - line("w0")])}'

-- The text to display before the user query in the completion prompt.
local prompt_prefix = ' > '

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

local function remove_text(bufnr, text, line, column)
  api.nvim_buf_set_text(bufnr, line - 1, column, line - 1, column + #text, {})
  api.nvim_win_set_cursor(0, { line, column })
end

-- Inserts the final completion into the buffer.
local function insert_completion(prefix, item)
  local bufnr = api.nvim_get_current_buf()

  remove_text(bufnr, prefix, item.line, item.column)

  if item.additional_edits then
    lsp.util.apply_text_edits(item.additional_edits, bufnr, 'utf-8')
  end

  if item.source == 'lsp' or item.source == 'snippet' then
    snippet.expand_snippet(item.insert)
  else
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

  for _, snippet in ipairs(snippet.list(vim.bo[buffer].ft)) do
    if vim.startswith(snippet.prefix, prefix) then
      table.insert(snippets, {
        filter = snippet.prefix,
        label = snippet.prefix,
        insert = snippet.body,
        kind = snippet_kind,
        docs = {
          kind = 'plain',
          value = snippet.desc,
        },
        source = 'snippet',
        line = line,
        column = column,
      })
    end
  end

  return snippets
end

-- Returns completion items for words in the current buffer.
function buffer_completion_items(column, prefix)
  if prefix == '' then
    return {}
  end

  local window = api.nvim_get_current_win()
  local buffer = api.nvim_win_get_buf(window)
  local words = {}
  local line = api.nvim_win_get_cursor(window)[1]
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

local function highlight_match(buf, line, start, stop)
  api.nvim_buf_add_highlight(
    buf,
    namespace,
    'TelescopeMatching',
    line - 1,
    start - 1,
    stop
  )
end

local function update_extmark_text(state)
  local buf = api.nvim_win_get_buf(state.window)
  local line, _ = unpack(api.nvim_win_get_cursor(state.results.window))
  local item = state.data.filtered[line]
  local text = ''

  if item then
    if item.source == 'lsp' or item.source == 'snippet' then
      -- Snippets may expand to many lines, so we'll only show the first line in
      -- the extmark text.
      text =
        vim.split(snippet.format(item.insert), '\n', { trimempty = true })[1]
    else
      text = item.insert
    end
  end

  if #state.prefix > 0 then
    text = text:sub(#state.prefix + 1, #text)
  end

  api.nvim_buf_set_extmark(
    buf,
    namespace,
    state.extmark.row,
    state.extmark.col,
    {
      id = state.extmark.id,
      virt_text = { { text, 'Comment' } },
      virt_text_pos = 'inline',
    }
  )
end

local function close_menu(state)
  api.nvim_clear_autocmds({ group = augroup })
  api.nvim_buf_del_extmark(
    api.nvim_win_get_buf(state.window),
    namespace,
    state.extmark.id
  )

  api.nvim_win_close(state.prompt.window, true)
  api.nvim_win_close(state.results.window, true)
  api.nvim_buf_delete(state.prompt.buffer, { force = true })
  api.nvim_buf_delete(state.results.buffer, { force = true })
  api.nvim_set_current_win(state.window)
  api.nvim_feedkeys('a', 'n', true)
end

local function select_menu_item(state, index)
  close_menu(state)

  local item = state.data.filtered[index]

  if item then
    insert_completion(state.prefix, item)
  end
end

local function move_menu_selection_down(state)
  local max = fn.line('$', state.results.window)
  local line, _ = unpack(api.nvim_win_get_cursor(state.results.window))
  local new_line = line < max and line + 1 or 1

  api.nvim_win_set_cursor(state.results.window, { new_line, 0 })
  update_extmark_text(state)
end

local function move_menu_selection_up(state)
  local line = api.nvim_win_get_cursor(state.results.window)[1]
  local new_line = line == 1 and fn.line('$', state.results.window) or line - 1

  api.nvim_win_set_cursor(state.results.window, { new_line, 0 })
  update_extmark_text(state)
end

local function configure_results_window(state)
  api.nvim_win_set_hl_ns(state.results.window, namespace)
  api.nvim_set_option_value(
    'cursorline',
    #state.data.filtered > 0,
    { win = state.results.window }
  )

  api.nvim_set_option_value(
    'cursorlineopt',
    'number,line',
    { win = state.results.window }
  )

  api.nvim_set_option_value('foldcolumn', '0', { win = state.results.window })
  api.nvim_set_option_value('signcolumn', 'no', { win = state.results.window })
  api.nvim_set_option_value('scrolloff', 0, { win = state.results.window })
  api.nvim_set_option_value(
    'statuscolumn',
    menu_status_col,
    { win = state.results.window }
  )
end

local function menu_size(items)
  local screen_height = api.nvim_get_option_value('lines', {})
  local screen_width = api.nvim_get_option_value('columns', {})
  local rows = menu_rows
  local cols = menu_columns

  if screen_height <= 15 then
    rows = math.floor(rows * 0.3)
  elseif screen_height < 20 then
    rows = math.floor(rows * 0.5)
  end

  if screen_width <= 65 then
    cols = math.floor(cols * 0.7)
  end

  return math.min(rows, items), cols
end

local function set_menu_position(state, initial)
  local reconfigure = false
  local win_row = api.nvim_win_get_position(state.results.window)[1]
  local screen_height = api.nvim_get_option_value('lines', {})
  local new_conf = nil

  if win_row + menu_rows >= screen_height then
    -- If the results window (using its default size) doesn't fit below the
    -- prompt, we'll place it above the prompt.
    new_conf = {
      anchor = menu_above_anchor,
      row = 0,
      col = 0,
      relative = 'win',
      win = state.prompt.window,
    }
  elseif
    api.nvim_win_get_config(state.results.window).anchor == menu_above_anchor
  then
    -- Move the results window back to its original place.
    new_conf = {
      anchor = menu_below_anchor,
      row = 1,
      col = 0,
      relative = 'win',
      win = state.prompt.window,
    }
  end

  if new_conf then
    api.nvim_win_set_config(state.results.window, new_conf)
  end

  if new_conf or initial then
    configure_results_window(state)
  end
end

local function set_menu_size(state)
  local new_height, new_width = menu_size(#state.data.filtered)

  api.nvim_win_set_height(state.results.window, new_height)
  api.nvim_win_set_width(state.results.window, new_width)
  api.nvim_win_set_width(state.prompt.window, new_width)
end

local function set_menu_items(state)
  -- I got 99 problems, but 100 lines ain't one. This is to ensure the
  -- statuscolumn padding isn't increased more, and to ensure the menu/filtering
  -- doesn't slow down.
  if #state.data.filtered >= 100 then
    local filtered = {}

    for i, item in ipairs(state.data.filtered) do
      if i < 100 then
        table.insert(filtered, item)
      else
        break
      end
    end

    state.data.filtered = filtered
  end

  local items = state.data.filtered
  local win = state.results.window
  local buf = state.results.buffer
  local prefix = state.prefix
  local lines = vim.tbl_map(function(i)
    return i.label
  end, items)

  api.nvim_buf_clear_namespace(buf, namespace, 0, -1)

  if #items == 0 then
    api.nvim_buf_set_lines(buf, 0, -1, false, { 'No results' })
    api.nvim_buf_add_highlight(buf, namespace, 'Comment', 0, 0, -1)
    api.nvim_set_option_value(
      'cursorline',
      false,
      { win = state.results.window }
    )
  else
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    api.nvim_set_option_value(
      'cursorline',
      true,
      { win = state.results.window }
    )
  end

  api.nvim_win_set_cursor(win, { 1, 0 })
  set_menu_size(state)

  for line = 1, #items do
    highlight_match(buf, line, 1, #prefix)
  end

  update_extmark_text(state)
end

local function filter_menu_items(state)
  local items = state.data.raw
  local query = api.nvim_buf_get_lines(state.prompt.buffer, 0, 1, false)[1]
    or ''

  -- The prompt and its prefix are treated as buffer text, so we need to remove
  -- the prefix to get the query text.
  if #query > 0 and #prompt_prefix > 0 then
    query = query:sub(#prompt_prefix + 1, #query)
  end

  if query == '' then
    state.data.filtered = items
    set_menu_items(state)
    return
  end

  local words = vim.split(query, '%s+', { trimempty = true })
  local results = {}

  for _, item in ipairs(items) do
    table.insert(results, { item = item, highlights = {} })
  end

  for _, word in ipairs(words) do
    local new_results = {}

    for i, result in ipairs(results) do
      local positions = {}
      local cursor = 1
      local matched = false

      while true do
        local start, stop = result.item.filter:find(word, cursor)

        if start == nil then
          break
        else
          matched = true
          cursor = start + 1
          positions[start] = stop
        end
      end

      if matched then
        table.insert(result.highlights, positions)
        table.insert(new_results, result)
      end
    end

    results = new_results
  end

  table.sort(results, function(a, b)
    return a.item.label < b.item.label
  end)

  state.data.filtered = vim.tbl_map(function(r)
    return r.item
  end, results)

  set_menu_items(state)

  for i, result in ipairs(results) do
    for _, ranges in ipairs(result.highlights) do
      for start, stop in pairs(ranges) do
        highlight_match(state.results.buffer, i, start, stop)
      end
    end
  end
end

local function define_highlights()
  local num_hl = api.nvim_get_hl(0, { name = 'Number' })
  local pmenu_sel_hl = api.nvim_get_hl(0, { name = 'PmenuSel' })

  api.nvim_set_hl(
    namespace,
    'CursorLineNr',
    { fg = num_hl.fg, bg = pmenu_sel_hl.bg, bold = true }
  )

  api.nvim_set_hl(namespace, 'LineNr', { link = 'Number' })
  api.nvim_set_hl(namespace, 'CursorLine', { link = 'PmenuSel' })
end

local function show_menu(buf, prefix, items)
  -- We define the highlights when showing the menu, such that any color
  -- (scheme) changes are picked up, without needing to define any global auto
  -- commands.
  define_highlights()

  local prev_win = api.nvim_get_current_win()

  -- The prompt buffer is set relative to the line/column, not the cursor, as
  -- resizing the window doesn't result in the cursor position being updated,
  -- resulting in the prompt clipping through the results window.
  local row, col = unpack(api.nvim_win_get_cursor(prev_win))
  local prompt_text = prompt_prefix .. prefix
  local prompt_buf = api.nvim_create_buf(false, true)
  local prompt_win = api.nvim_open_win(prompt_buf, true, {
    row = 1,
    col = 0 - #prompt_text,
    bufpos = { row - 1, col },
    relative = 'win',
    win = prev_win,
    anchor = menu_below_anchor,
    width = menu_columns,
    height = 1,
    focusable = true,
    style = 'minimal',
    border = 'none',
  })

  local results_buf = api.nvim_create_buf(false, true)
  local results_win = api.nvim_open_win(results_buf, false, {
    row = 1,
    col = 0,
    relative = 'win',
    win = prompt_win,
    anchor = menu_below_anchor,
    width = menu_columns,
    height = menu_rows,
    focusable = false,
    style = 'minimal',
    border = 'none',
    noautocmd = true,
  })

  local mark = api.nvim_buf_set_extmark(
    api.nvim_win_get_buf(prev_win),
    namespace,
    row - 1,
    col - #prefix,
    {
      virt_text = {},
      virt_text_pos = 'overlay',
    }
  )

  local state = {
    prompt = { window = prompt_win, buffer = prompt_buf },
    results = { window = results_win, buffer = results_buf },
    data = { raw = items, filtered = items },
    window = prev_win,
    prefix = prefix,
    extmark = {
      id = mark,
      row = row - 1,
      col = col,
    },
    col = col,
  }

  api.nvim_buf_set_name(state.prompt.buffer, 'Completion')
  api.nvim_set_option_value('buftype', 'prompt', { buf = state.prompt.buffer })
  api.nvim_set_option_value('buftype', 'nofile', { buf = state.results.buffer })

  set_menu_items(state)

  -- The position is determined initially and when resizing the window. This
  -- ensures that filtering results doesn't result in the window moving around.
  set_menu_position(state, true)

  fn.prompt_setprompt(state.prompt.buffer, prompt_text)
  fn.prompt_setinterrupt(state.prompt.buffer, function()
    close_menu(state)
  end)

  fn.prompt_setcallback(state.prompt.buffer, function()
    select_menu_item(state, api.nvim_win_get_cursor(state.results.window)[1])
  end)

  -- The numbers 0..9 are used to quickly pick an item, removing the need for
  -- needless typing of tabbing.
  for i = 0, 9 do
    vim.keymap.set('i', tostring(i), function()
      select_menu_item(state, fn.line('w0', state.results.window) + i)
    end, { buffer = state.prompt.buffer, silent = true, noremap = true })
  end

  -- Tab and Shift+Tab are used for scrolling through the list of candidates.
  for _, key in ipairs({ '<Tab>', '<Down>' }) do
    vim.keymap.set('i', key, function()
      move_menu_selection_down(state)
    end, { buffer = state.prompt.buffer, silent = true, noremap = true })
  end

  for _, key in ipairs({ '<S-Tab>', '<Up>' }) do
    vim.keymap.set('i', key, function()
      move_menu_selection_up(state)
    end, { buffer = state.prompt.buffer, silent = true, noremap = true })
  end

  api.nvim_create_autocmd('InsertLeave', {
    buffer = state.prompt.buffer,
    callback = function()
      close_menu(state)
      return true
    end,
  })

  local text_changed_first_time = true

  api.nvim_create_autocmd('TextChangedI', {
    group = augroup,
    buffer = state.prompt.buffer,
    callback = function()
      -- When showing the window the first time, this event gets triggered right
      -- away, probably due to the use of prompt_setprompt(). This check ensures
      -- we ignore said first event.
      if text_changed_first_time then
        text_changed_first_time = false

        -- If we set this up outside this autocmd then the highlight doesn't get
        -- applied. I have no idea why, but doing it here (once) works :|
        if #prompt_prefix > 0 then
          api.nvim_buf_add_highlight(
            state.prompt.buffer,
            -1,
            'TelescopePromptPrefix',
            0,
            0,
            #prompt_prefix
          )
        end

        return
      end

      filter_menu_items(state)
    end,
  })

  api.nvim_create_autocmd('WinScrolled', {
    group = augroup,
    pattern = tostring(state.results.window),
    callback = function()
      -- This is needed to refresh the status column.
      -- https://github.com/neovim/neovim/pull/25885 should (hopefully) fix
      -- this when it's released.
      api.nvim_set_option_value(
        'statuscolumn',
        menu_status_col,
        { win = state.results.window }
      )
    end,
  })

  api.nvim_create_autocmd('VimResized', {
    group = augroup,
    callback = function()
      set_menu_size(state)
      set_menu_position(state)
    end,
  })
end

local function show_completions(bufnr, prefix, items)
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
    return a.label < b.label
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

    -- If the entries are a variable and a module, we favour the variable, as
    -- variable completion occurs more frequently than module completion.
    if items[1].kind == variable_kind and items[2].kind == module_kind then
      insert_completion(prefix, items[1])
      return
    elseif items[1].kind == module_kind and items[2].kind == variable_kind then
      insert_completion(prefix, items[2])
      return
    end
  end

  show_menu(bufnr, prefix, items)
end

-- Performs a fallback completion if a language server client isn't available.
local function fallback_completion(column, prefix)
  local bufnr = api.nvim_get_current_buf()
  local items = snippet_completion_items(bufnr, column, prefix)
  local words = buffer_completion_items(column, prefix)

  vim.list_extend(items, words)
  show_completions(bufnr, prefix, items)
end

local function lsp_items(result, query)
  local items = {}

  if type(result) == 'table' and result.items then
    items = result.items
  elseif result ~= nil then
    items = result
  end

  items = vim.tbl_filter(function(item)
    local word = filter_text(item)

    return vim.startswith(word, query) and not ignored_kinds[item.kind]
  end, items)

  return items
end

function M.start()
  local line, column, prefix = unpack(completion_position())
  local bufnr = api.nvim_get_current_buf()

  if not util.has_lsp_clients_supporting(bufnr, 'completion') then
    return fallback_completion(column, prefix)
  end

  local params = lsp.util.make_position_params(0)
  local items = snippet_completion_items(bufnr, column, prefix)

  lsp.buf_request(
    bufnr,
    'textDocument/completion',
    params,
    function(err, result)
      if err or not result then
        show_completions(bufnr, prefix, items)
        return
      end

      for _, item in ipairs(lsp_items(result, prefix)) do
        local filter = filter_text(item)

        table.insert(items, {
          filter = filter,
          label = item.label or filter,
          insert = text_to_expand(item),
          additional_edits = item.additionalTextEdits,
          kind = item.kind,
          docs = item.documentation,
          detail = item.detail,
          source = 'lsp',
          line = line,
          column = column,
        })
      end

      show_completions(bufnr, prefix, items)
    end
  )
end

return M
