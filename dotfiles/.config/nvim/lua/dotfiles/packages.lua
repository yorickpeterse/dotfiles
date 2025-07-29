local pkg = require('dotfiles.package')
local use = pkg.use

use('neovim/nvim-lspconfig')
use({ 'nvim-treesitter/nvim-treesitter', branch = 'main', run = 'TSUpdate' })
use('inko-lang/inko.vim')
use('yorickpeterse/rust.vim')
use('yorickpeterse/nvim-grey')
use('yorickpeterse/nvim-window')
use('yorickpeterse/nvim-pqf')
use('yorickpeterse/nvim-dd')
use('yorickpeterse/nvim-tree-pairs')
use('mfussenegger/nvim-lint')
use('stevearc/oil.nvim')
use('stevearc/conform.nvim')
use('folke/flash.nvim')
use('echasnovski/mini.nvim')

pkg.install()
