local g = vim.g
local o = vim.opt
local fn = vim.fn

-- Settings to set before loading plugins
g.python3_host_prog = '/usr/bin/python'
g.python_host_prog = '/usr/bin/python2'

-- Disable matchparen, as I don't use it and sometimes leads to errors when
-- opening quickfix windows (https://github.com/neovim/neovim/issues/17157).
g.loaded_matchparen = 1

-- (Neo)Vim's built-in Zig plugin tries to auto format code, but in doing so may
-- pop open a tiny location list if there are errors. I disable this here since
-- I use a different plugin for formatting anyway.
g.zig_fmt_autosave = 0

-- Enable faster loading of Lua modules.
vim.loader.enable()

require('dotfiles.packages')

-- Colorscheme
vim.cmd('color grey')

-- Config files and plugins
require('pqf').setup()
require('dd').setup()
require('tree-pairs').setup()

require('dotfiles.lsp')
require('dotfiles.window')
require('dotfiles.treesitter')
require('dotfiles.flash')
require('dotfiles.hooks')
require('dotfiles.oil')
require('dotfiles.linters')
require('dotfiles.formatters')
require('dotfiles.pairs')
require('dotfiles.maps')
require('dotfiles.commands')
require('dotfiles.abbrev')
require('dotfiles.mini')

-- Code completion
o.pumheight = 30
o.completeopt = 'menu'
o.complete = { '.', 'b' }
o.wildignorecase = true

-- Generic
o.colorcolumn = '80'
o.number = true
o.relativenumber = true
o.numberwidth = 3
o.ruler = false
o.signcolumn = 'yes'
o.foldcolumn = '0'
o.synmaxcol = 256
o.termguicolors = true
o.textwidth = 80
o.wrap = false
o.linebreak = true
o.cursorcolumn = false
o.cursorline = true
o.cursorlineopt = 'number'
o.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'
o.backspace = 'indent,eol,start'
o.backupskip = '/tmp/*'
o.diffopt =
  'filler,vertical,internal,algorithm:histogram,indent-heuristic,context:3,linematch:50'
o.lz = true
o.showcmd = false
o.showmode = false
o.splitright = true
o.splitbelow = true
o.splitkeep = 'screen'
o.title = true
o.titlestring = '%t'
o.mouse = ''
o.shortmess = 'atOIcF'
o.inccommand = 'nosplit'
o.scrollback = 1000
o.scrolloff = 2
o.updatetime = 1000
o.fillchars = {
  fold = ' ',
  diff = '╱',
  wbr = ' ',
  msgsep = '─',
}
o.jumpoptions = 'stack'
o.regexpengine = 0
o.list = true
o.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
o.winheight = 5
o.path = '.,,'
o.formatexpr = "v:lua.require'conform'.formatexpr()"
o.shada = "!,'0,<50,s10,h,f0"
o.winborder = 'rounded'

-- GUI
do
  local name = 'IosevkaFixedCustom Nerd Font'
  local size = '8'

  o.linespace = 0
  o.guifont = name .. ':h' .. size
  o.guifontwide = 'Noto Color Emoji:h' .. size
end

-- Indentation
o.expandtab = true
o.shiftwidth = 4
o.shiftround = true
o.softtabstop = 4
o.tabstop = 4

-- Markdown
g.markdown_fenced_languages = { 'ruby', 'rust', 'sql', 'inko', 'yaml', 'lua' }

-- netrw
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- Rust
g.rust_recommended_style = 0

-- Searching
o.grepprg = 'rg --vimgrep'
o.grepformat = '%f:%l:%c:%m,%f:%l:%m'
o.incsearch = true
o.hlsearch = false

-- Statuscolumn
o.statuscolumn =
  '%s%=%{&relativenumber ? (v:virtnum == 0 ? (v:relnum > 0 ? v:relnum : v:lnum) : " ") : ""} '

-- Statusline
o.statusline = "%!v:lua.require'dotfiles.statusline'.render()"
o.laststatus = 3
g.qf_disable_statusline = true

-- RPM spec files
g.no_spec_maps = true

-- Window bar
o.winbar = "%!v:lua.require'dotfiles.winbar'.render()"

-- Tabline
o.tabline = ''
o.showtabline = 0
