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

      if conf.relative == 'cursor' then
        conf.col = -1
        conf.row = 4
      end

      return conf
    end,
    get_config = function(opts)
      if opts.kind == 'center' then
        return { relative = 'editor' }
      end
    end,
  },
  select = {
    backend = { 'telescope' },
    telescope = {
      layout_strategy = 'grey',
      layout_config = {
        width = 60,
        height = 10,
        preview_width = 0.6,
      },
      prompt_title = false,
      results_title = false,
      preview_title = false,
    },
    get_config = function(opts)
      if opts.kind == 'codeaction' then
        return {
          telescope = {
            layout_strategy = 'grey_cursor',
          },
        }
      end
    end,
  },
})
