local package = require('dotfiles.package')
local use = package.use

use 'windwp/nvim-autopairs'
use 'YorickPeterse/rust.vim'
use 'preservim/nerdcommenter'
use 'tpope/vim-fugitive'
use 'dag/vim-fish'
use 'ludovicchabant/vim-gutentags'
use 'junegunn/fzf'
use 'junegunn/fzf.vim'
use 'Vimjas/vim-python-pep8-indent'
use 'yssl/QFEnter'
use 'neovim/nvim-lspconfig'
use 'hrsh7th/vim-vsnip'
use { 'https://gitlab.com/inko-lang/inko.vim', branch = 'single-ownership' }
use 'https://gitlab.com/yorickpeterse/vim-paper'
use 'phaazon/hop.nvim'

package.install()
