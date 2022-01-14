local pkg = require('dotfiles.package')
local use = pkg.use

use('nvim-lua/plenary.nvim')
use('b3nj5m1n/kommentary')
use('YorickPeterse/rust.vim')
use('tpope/vim-fugitive')
use('dag/vim-fish')
use('ludovicchabant/vim-gutentags')
use('Vimjas/vim-python-pep8-indent')
use('neovim/nvim-lspconfig')
use('dcampos/nvim-snippy')
use({ 'https://gitlab.com/inko-lang/inko.vim', branch = 'single-ownership' })
use('https://gitlab.com/yorickpeterse/nvim-grey')
use('https://gitlab.com/yorickpeterse/nvim-window')
use('https://gitlab.com/yorickpeterse/nvim-pqf')
use('https://gitlab.com/yorickpeterse/nvim-dd')
use('phaazon/hop.nvim')
use('kyazdani42/nvim-web-devicons')
use('justinmk/vim-dirvish')
use('sindrets/diffview.nvim')
use('nvim-telescope/telescope.nvim')
use({ 'nvim-telescope/telescope-fzf-native.nvim', run = '!make' })
use({
  'nvim-treesitter/nvim-treesitter',
  -- Automatically install/update these parsers when installing/updating.
  run = 'silent TSUpdate bash c comment fish go javascript json lua python ruby rust toml yaml',
})
use('whiteinge/diffconflicts')
use('jose-elias-alvarez/null-ls.nvim')

pkg.install()
