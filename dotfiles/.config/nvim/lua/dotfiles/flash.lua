require('flash').setup({
  labels = 'tnseriaogmplfuwyqbjdhvkzxc',
  modes = {
    search = { enabled = false },
    char = { enabled = false },
    treesitter = {
      label = { before = true, after = false, style = 'overlay' },
    },
  },
  prompt = {
    win_config = { border = 'none' },
  },
  label = {
    before = false,
    after = true,
  },
})
