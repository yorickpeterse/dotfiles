require('dotfiles/lsp')

-- Here we export some modules into the global namespace, making it easier to
-- use them through Vimscript.
_G.dotfiles = {
  completion = require('dotfiles/completion')
}
