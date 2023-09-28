require('dressing').setup({
  input = {
    win_options = {
      winblend = 0,
    },
    title_pos = 'left',
    border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    override = function(conf)
      conf.col = -1
      conf.row = 2

      return conf
    end,
  },
  select = {
    backend = { 'telescope' },
  },
})
