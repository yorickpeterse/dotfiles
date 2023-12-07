require('dressing').setup({
  input = {
    win_options = {
      winblend = 0,
    },
    title_pos = 'left',
    border = {
      ' ', -- top left
      ' ', -- top
      ' ', -- top right
      ' ', -- right
      '', -- bottom right
      '', -- bottom
      '', -- bottom left
      ' ', -- left
    },
    override = function(conf)
      -- Trim surrounding whitespace and trailing colons from the prompt.
      conf.title = vim.trim(conf.title)

      if vim.endswith(conf.title, ':') then
        conf.title = conf.title:sub(1, -2)
      end

      conf.col = -1
      conf.row = 1

      return conf
    end,
  },
  select = {
    backend = { 'telescope' },
    telescope = {
      layout_strategy = 'grey_cursor',
      layout_config = {
        width = 60,
        height = 10,
        preview_width = 0.6,
      },
      prompt_title = false,
      results_title = false,
      preview_title = false,
    },
  },
})
