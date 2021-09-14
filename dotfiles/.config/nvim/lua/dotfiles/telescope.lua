local telescope = require('telescope')
local actions = require('telescope.actions')
local sorters = require('telescope.sorters')

local picker_defaults = {
  previewer = false,
  prompt_title = false,
  results_title = false,
  preview_title = false,
}

local function picker_opts(opts)
  return vim.tbl_extend('force', picker_defaults, opts or {})
end

telescope.setup {
  defaults = {
    prompt_prefix = '> ',
    sorting_strategy = 'ascending',
    layout_strategy = 'center',
    layout_config = {
      prompt_position = 'top',
      width = 0.7,
      height = 0.6,
    },
    borderchars = {
      prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
      results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
      preview = {  '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    },
    mappings = {
      i = {
        ['<tab>'] = actions.move_selection_next,
        ['<s-tab>'] = actions.move_selection_previous,
      },
      n = {
        ['<tab>'] = actions.move_selection_next,
        ['<s-tab>'] = actions.move_selection_previous,
      }
    },
    file_ignore_patterns = {
      '.git/',
    }
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
    treesitter = picker_opts({ show_line = false }),
    reloader = picker_defaults,
  },
  extensions = {
    fzf = {
      fuzzy = false,
      override_generic_sorter = true,
      override_file_sorter = true
    },
  },
}

telescope.load_extension('fzf')
