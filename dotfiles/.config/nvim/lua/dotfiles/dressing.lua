require('dressing').setup({
  input = {
    win_options = {
      winblend = 0,
      winhighlight = 'NormalFloat:TelescopePromptNormal,'
        .. 'FloatBorder:TelescopePromptBorder,'
        .. 'FloatTitle:TelescopePromptTitle',
    },
    title_pos = 'left',
    border = {
      ' ', -- top left
      ' ', -- top
      ' ', -- top right
      ' ', -- right
      ' ', -- bottom right
      ' ', -- bottom
      ' ', -- bottom left
      ' ', -- left
    },
    override = function(conf)
      -- Trim surrounding whitespace and trailing colons from the prompt.
      conf.title = vim.trim(conf.title)

      if vim.endswith(conf.title, ':') then
        conf.title = conf.title:sub(1, -2)
      end

      conf.col = -1
      conf.row = 2

      return conf
    end,
  },
  select = {
    backend = { 'telescope' },
    telescope = {
      layout_strategy = 'completion',
      layout_config = { overlay = false },
      prompt_title = false,
      results_title = false,
      preview_title = false,
    },
  },
})
