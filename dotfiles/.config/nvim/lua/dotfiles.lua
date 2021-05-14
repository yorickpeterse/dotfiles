require('dotfiles/lsp')
require('dotfiles/linting')

-- Here we export some modules into the global namespace, making it easier to
-- use them through Vimscript.
_G.dotfiles = {
  completion = require('dotfiles/completion'),

  show_line_diagnostics = function()
    local bufnr = vim.fn.bufnr('')

    vim.lsp.diagnostic.show_line_diagnostics(
      { severity_limit = 'Warning' },
      bufnr
    )
  end
}
