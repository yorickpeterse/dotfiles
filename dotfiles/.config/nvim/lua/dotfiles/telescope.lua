local telescope = require('telescope')
local actions = require('telescope.actions')
local sorters = require('telescope.sorters')
local layout = require('telescope.actions.layout')
local strats = require('telescope.pickers.layout_strategies')
local p_window = require('telescope.pickers.window')
local api = vim.api
local fn = vim.fn

local picker_defaults = {
  previewer = false,
  show_line = false,
  results_title = false,
  prompt_title = false,
  preview_title = false,
}

local function picker_opts(opts)
  return vim.tbl_extend('force', picker_defaults, opts or {})
end

strats.completion = function(self, max_columns, max_lines, layout_config)
  local initial_options = p_window.get_initial_window_options(self)
  local results = initial_options.results
  local prompt = initial_options.prompt
  local preview = initial_options.preview

  local win_id = self.original_win_id
  local win_height = api.nvim_win_get_height(win_id)
  local win_width = api.nvim_win_get_width(win_id)
  local win_line, win_col = unpack(api.nvim_win_get_position(win_id))
  local cursor_line = api.nvim_win_call(win_id, fn.winline)
  local cursor_col = api.nvim_win_call(win_id, fn.wincol)
  local border = self.window.border and 1 or 0

  cursor_line = cursor_line + win_line
  cursor_col = cursor_col + win_col

  if
    vim.o.showtabline == 2
    or (vim.o.showtabline == 1 and #api.nvim_list_tabpages() > 1)
  then
    cursor_line = cursor_line + 1
  end

  if vim.wo[win_id].winbar ~= '' then
    cursor_line = cursor_line + 1
  end

  local prompt_height = 1
  local result_height = math.min(#self.finder.results, 5)
  local width = 80
  local show_preview = self.previewer and max_columns >= 110

  if show_preview then
    width = width + 20
    result_height = result_height + 10
  end

  local height = result_height + (border * 3) + prompt_height
  local line = cursor_line
  local col = cursor_col

  if #self.default_text > 0 then
    col = col - api.nvim_strwidth(self.default_text) -- + 1
  end

  local above = false

  -- If the bottom of the popup clips outside of the viewport, we place the
  -- prompt above the cursor line, and the results/preview above that. So
  -- instead of this (`|` is the cursor):
  --
  --     text|
  --         +-------------+
  --         | Prompt      |
  --         +-------------+
  --         | Results     |
  --         +-------------+
  --
  -- We end up with this:
  --
  --         +-------------+
  --         | Results     |
  --         +-------------+
  --         | Prompt      |
  --         +-------------+
  --     text|
  if max_lines >= 20 and ((line + height - (border * 2)) > max_lines) then
    above = true
  end

  local top_right = col + width

  if top_right >= max_columns then
    -- Adjust the position to be further to the left of the cursor, to prevent
    -- the window from clipping out of the viewport.
    col = math.max(1 + border, col - (top_right - max_columns))

    -- The width is adjusted as well, such that as the viewport gets smaller, so
    -- does the popup.
    width = math.max(40, max_columns - col - (border * 2))
  end

  prompt.line = line
  prompt.borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
  prompt.col = col
  prompt.height = prompt_height
  prompt.width = width

  if above then
    results.line = prompt.line - result_height - border
    results.borderchars = { ' ', ' ', '─', ' ', ' ', ' ', ' ', ' ' }
  else
    results.line = prompt.line + prompt.height + border
    results.borderchars = { '─', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
  end

  results.col = col
  results.width = width
  results.height = result_height

  if show_preview then
    preview.width = math.ceil(width * 0.7)
    results.width = math.ceil(width - preview.width)
    preview.title = false
    preview.col = results.col + results.width
    preview.line = results.line
    preview.height = results.height
  end

  if above then
    preview.borderchars = { ' ', ' ', '─', '│', ' ', ' ', ' ', '┴' }
  else
    preview.borderchars = { '─', ' ', ' ', '│', '┬', ' ', ' ', ' ' }
  end

  return {
    preview = show_preview and preview,
    prompt = prompt,
    results = results,
  }
end

telescope.setup({
  defaults = {
    prompt_prefix = '',
    entry_prefix = ' ',
    selection_caret = ' ',
    sorting_strategy = 'ascending',
    layout_strategy = 'grey',
    layout_config = {
      prompt_position = 'top',
      width = 0.6,
      height = 0.5,
      preview_width = 0.6,
    },
    preview = {
      hide_on_startup = true,
    },
    mappings = {
      i = {
        ['<tab>'] = actions.move_selection_next,
        ['<s-tab>'] = actions.move_selection_previous,
        ['<C-p>'] = layout.toggle_preview,
      },
      n = {
        ['<tab>'] = actions.move_selection_next,
        ['<s-tab>'] = actions.move_selection_previous,
      },
    },
    file_ignore_patterns = {
      '.git/',
    },
  },
  pickers = {
    file_browser = picker_defaults,
    find_files = picker_defaults,
    git_files = picker_defaults,
    buffers = picker_defaults,
    tags = picker_defaults,
    current_buffer_tags = picker_defaults,
    lsp_references = picker_defaults,
    lsp_document_symbols = picker_defaults,
    lsp_workspace_symbols = picker_defaults,
    lsp_implementations = picker_defaults,
    lsp_definitions = picker_defaults,
    git_commits = picker_defaults,
    git_bcommits = picker_defaults,
    git_branches = picker_defaults,
    treesitter = picker_defaults,
    reloader = picker_defaults,
  },
  extensions = {
    fzf = {
      fuzzy = false,
      override_generic_sorter = true,
      override_file_sorter = true,
    },
  },
})

telescope.load_extension('fzf')
telescope.load_extension('grey')
