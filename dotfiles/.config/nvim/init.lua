-- vim: set fdm=marker
local g = vim.g
local o = vim.opt

-- Settings to set before loading plugins {{{1
g.python3_host_prog = '/usr/bin/python'
g.python_host_prog = '/usr/bin/python2'

g.qfenter_keymap = {
  vopen = { '<leader>v' },
}

-- Config files and plugins {{{1
require('dotfiles.packages')

require('pqf').setup()
require('dd').setup()

require('dotfiles.lsp')
require('dotfiles.window')
require('dotfiles.git')
require('dotfiles.treesitter')
require('dotfiles.telescope')
require('dotfiles.comments')
require('dotfiles.hop')

_G.dotfiles = {
  completion = require('dotfiles.completion'),
  diagnostics = require('dotfiles.diagnostics'),
  package = require('dotfiles.package'),
  statusline = require('dotfiles.statusline'),
  tabline = require('dotfiles.tabline'),
  workspace = require('dotfiles.workspace'),
  abbrev = require('dotfiles.abbrev'),
  location_list = require('dotfiles.location_list'),
  maps = require('dotfiles.maps'),
  commands = require('dotfiles.commands'),
  hooks = require('dotfiles.hooks'),
  pairs = require('dotfiles.pairs'),
}

-- Colorscheme {{{1
vim.cmd('color grey')

-- Code completion {{{1
o.pumheight = 30
o.completeopt = 'menu'
o.complete = { '.', 'b' }
o.completefunc = 'v:lua.dotfiles.completion.start'

-- Fugitive {{{1
g.fugitive_dynamic_colors = 0

-- Generic {{{1
o.colorcolumn = '80'
o.number = true
o.relativenumber = true
o.ruler = false
o.signcolumn = 'yes'
o.synmaxcol = 256
o.termguicolors = true
o.textwidth = 80
o.wrap = false
o.cursorcolumn = false
o.cursorline = true
o.cursorlineopt = 'number'
o.backspace = 'indent,eol,start'
o.backupskip = '/tmp/*'
o.clipboard = 'unnamed'
o.diffopt =
  'filler,vertical,internal,algorithm:patience,indent-heuristic,context:3'
o.lz = true
o.showcmd = false
o.pastetoggle = '<F2>'
o.splitright = true
o.title = true
o.mouse = ''
o.shortmess = 'atOIcF'
o.inccommand = 'nosplit'
o.scrollback = 1000
o.updatetime = 1000
o.fillchars = { fold = ' ', diff = ' ' }
o.printoptions = { number = 'n', header = '0' }
o.regexpengine = 0
o.list = true
o.listchars = { tab = '  ', trail = '·', nbsp = '␣' }

-- Gutentags {{{1
g.gutentags_ctags_exclude = {
  'target',
  'tmp',
  'node_modules',
  'public',
  '*/fixtures/*',
  '*/locale/*',
  '*.json',
  '*.svg',
  '*.scss',
  '*.css',
  -- I use Treesitter for these languages, so don't index them.
  '*.rs',
  '*.lua',
  '*.js',
}

g.gutentags_exclude_filetypes = { 'lua' }
g.gutentags_file_list_command = 'rg --files'
g.gutentags_ctags_extra_args = { '--excmd=number' }

-- Indentation {{{1
o.expandtab = true
o.shiftwidth = 4
o.shiftround = true
o.softtabstop = 4
o.tabstop = 4

-- Markdown {{{1
g.markdown_fenced_languages = { 'ruby', 'rust', 'sql', 'inko', 'yaml' }

-- netrw {{{1
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- Rust {{{1
g.rust_recommended_style = 0

-- Searching {{{1
o.grepprg = 'rg --vimgrep'
o.grepformat = '%f:%l:%c:%m,%f:%l:%m'
o.incsearch = true
o.hlsearch = false

-- Statusline {{{1
o.statusline = '%!v:lua.dotfiles.statusline.render()'
g.qf_disable_statusline = true

-- Tabline {{{1
o.tabline = '%!v:lua.dotfiles.tabline.render()'
o.showtabline = 2
