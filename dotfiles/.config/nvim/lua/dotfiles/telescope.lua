local telescope = require('telescope')
local actions = require('telescope.actions')
local sorters = require('telescope.sorters')
local layout = require('telescope.actions.layout')
local strats = require('telescope.pickers.layout_strategies')

local picker_defaults = {
  previewer = false,
  show_line = false,
  results_title = false,
  prompt_title = false,
}

local function picker_opts(opts)
  return vim.tbl_extend('force', picker_defaults, opts or {})
end

strats.horizontal_merged = function(
  picker,
  max_columns,
  max_lines,
  layout_config
)
  local layout =
    strats.horizontal(picker, max_columns, max_lines, layout_config)

  layout.prompt.title = ''
  layout.prompt.borderchars =
    { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }

  layout.results.title = ''
  layout.results.borderchars =
    { '─', '│', '─', '│', '├', '┤', '╯', '╰' }

  layout.results.line = layout.results.line - 1
  layout.results.height = layout.results.height + 1

  if layout.preview then
    layout.preview.width = layout.preview.width + 1
    layout.preview.col = layout.preview.col - 1
    layout.preview.title = ''
    layout.preview.borderchars =
      { '─', '│', '─', '│', '┬', '╮', '╯', '┴' }
  end

  return layout
end

telescope.setup({
  defaults = {
    prompt_prefix = '> ',
    sorting_strategy = 'ascending',
    layout_strategy = 'horizontal_merged',
    layout_config = {
      prompt_position = 'top',
      width = 0.6,
      height = 0.5,
      preview_width = 0.5,
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
