require('dotfiles/lsp')
require('dotfiles/linting')
require('dotfiles/pairs')

_G.dotfiles = {
  completion = require('dotfiles/completion'),
  diagnostics = require('dotfiles/diagnostics'),
}
