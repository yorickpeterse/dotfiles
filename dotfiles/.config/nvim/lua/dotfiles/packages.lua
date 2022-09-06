local pkg = require('dotfiles.package')
local use = pkg.use

use('nvim-lua/plenary.nvim')
use('b3nj5m1n/kommentary')
use('YorickPeterse/rust.vim')
use('dag/vim-fish')
use('ludovicchabant/vim-gutentags')
use('Vimjas/vim-python-pep8-indent')
use('neovim/nvim-lspconfig')
use('dcampos/nvim-snippy')
use('https://gitlab.com/inko-lang/inko.vim')
use('https://gitlab.com/yorickpeterse/nvim-grey')
use('https://gitlab.com/yorickpeterse/nvim-window')
use('https://gitlab.com/yorickpeterse/nvim-pqf')
use('https://gitlab.com/yorickpeterse/nvim-dd')
use('phaazon/hop.nvim')
use('kyazdani42/nvim-web-devicons')
use('elihunter173/dirbuf.nvim')
use('sindrets/diffview.nvim')
use('nvim-telescope/telescope.nvim')
use({ 'nvim-telescope/telescope-fzf-native.nvim', run = '!make' })
use({
  'nvim-treesitter/nvim-treesitter',
  -- Automatically install/update these parsers when installing/updating.
  run = 'silent TSUpdate bash c comment fish go javascript json lua python ruby rust toml yaml',
})
use('jose-elias-alvarez/null-ls.nvim')
use('stevearc/dressing.nvim')

pkg.install()
