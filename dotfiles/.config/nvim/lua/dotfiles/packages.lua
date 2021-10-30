local pkg = require('dotfiles.package')
local use = pkg.use

use 'echasnovski/mini.nvim'
use 'YorickPeterse/rust.vim'
use 'tpope/vim-fugitive'
use 'dag/vim-fish'
use 'ludovicchabant/vim-gutentags'
use 'Vimjas/vim-python-pep8-indent'
use 'yssl/QFEnter'
use 'neovim/nvim-lspconfig'
use 'L3MON4D3/LuaSnip'
use { 'https://gitlab.com/inko-lang/inko.vim', branch = 'single-ownership' }
use 'https://gitlab.com/yorickpeterse/nvim-grey'
use 'https://gitlab.com/yorickpeterse/nvim-window'
use 'https://gitlab.com/yorickpeterse/nvim-pqf'
use 'https://gitlab.com/yorickpeterse/nvim-dd'
use 'phaazon/hop.nvim'
use 'kyazdani42/nvim-web-devicons'
use 'justinmk/vim-dirvish'
use 'sindrets/diffview.nvim'
use 'nvim-lua/popup.nvim'
use 'nvim-lua/plenary.nvim'
use 'nvim-telescope/telescope.nvim'
use { 'nvim-telescope/telescope-fzf-native.nvim', run = '!make' }
use {
  'nvim-treesitter/nvim-treesitter',
  -- Automatically install/update these parsers when installing/updating.
  run = 'silent TSUpdate bash c comment fish go javascript json lua python ruby rust toml yaml'
}
use 'whiteinge/diffconflicts'

pkg.install()
