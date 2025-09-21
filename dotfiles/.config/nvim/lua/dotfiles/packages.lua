-- Install and configure mini.deps

local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'

if not vim.loop.fs_stat(mini_path) then
  local clone_cmd = {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/nvim-mini/mini.nvim',
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
end

local deps = require('mini.deps')
local add = deps.add

deps.setup({ path = { package = path_package } })

-- Dependencies

add('neovim/nvim-lspconfig')
add({
  source = 'nvim-treesitter/nvim-treesitter',
  checkout = 'main',
  hooks = {
    post_checkout = function()
      vim.cmd('TSUpdate')
    end,
  },
})
add({ source = 'inko-lang/inko.vim' })
add({ source = 'yorickpeterse/rust.vim' })
add({ source = 'yorickpeterse/nvim-grey' })
add({ source = 'yorickpeterse/nvim-window' })
add({ source = 'yorickpeterse/nvim-pqf' })
add({ source = 'yorickpeterse/nvim-dd' })
add({ source = 'yorickpeterse/nvim-tree-pairs' })
add({ source = 'mfussenegger/nvim-lint' })
add({ source = 'stevearc/oil.nvim' })
add({ source = 'stevearc/conform.nvim' })
add({ source = 'folke/flash.nvim' })
add({ source = 'echasnovski/mini.nvim' })
add({ source = 'lewis6991/gitsigns.nvim' })
