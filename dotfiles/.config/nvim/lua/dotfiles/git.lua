require('neogit').setup({
  disable_insert_on_commit = true,
  graph_style = 'unicode',
  status = {
    recent_commit_count = 20,
  },
  commit_view = {
    verify_commit = false,
  },
  signs = {
    hunk = { '', '' },
    item = { '', '' },
    section = { '', '' },
  },
  integrations = {
    telescope = true,
    diffview = true,
  },
})
