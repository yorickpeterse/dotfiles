require('dressing').setup({
  input = {
    win_options = {
      winblend = 0,
    },
    override = function(conf)
      -- The window is placed one cell to the right of the cursor. This can look
      -- out of place. For example:
      --
      --     let [n]ame = x
      --
      -- Here `[n]` indicates the cursor is on the letter "n". When opening the
      -- input window, it's placed like so:
      --
      --     let [n]ame = x
      --            +-New Name:---------+
      --            |                   |
      --            +-------------------+
      --
      -- By setting the column to 0 we shift we window one cell to the left,
      -- resulting in this:
      --
      --     let [n]ame = x
      --         +-New Name:---------+
      --         |                   |
      --         +-------------------+
      conf.col = 0
      conf.row = 4

      return conf
    end,
  },
  select = {
    backend = { 'telescope' },
  },
})
