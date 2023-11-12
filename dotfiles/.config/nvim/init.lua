local g = vim.g
local o = vim.opt
local fn = vim.fn

-- Settings to set before loading plugins
g.python3_host_prog = '/usr/bin/python'
g.python_host_prog = '/usr/bin/python2'

-- Disable matchparen, as I don't use it and sometimes leads to errors when
-- opening quickfix windows (https://github.com/neovim/neovim/issues/17157).
g.loaded_matchparen = 1

-- Enable faster loading of Lua modules.
vim.loader.enable()

require('dotfiles.packages')

-- Colorscheme
vim.cmd('color grey')

-- Config files and plugins
require('pqf').setup()
require('dd').setup()
require('dotfiles.lsp')
require('dotfiles.window')
require('dotfiles.git')
require('dotfiles.treesitter')
require('dotfiles.telescope')
require('dotfiles.comments')
require('dotfiles.dressing')
require('dotfiles.hooks')
require('dotfiles.pounce')
require('dotfiles.devicons')
require('dotfiles.oil')
require('dotfiles.linters')
require('dotfiles.formatters')
require('dotfiles.pairs')
require('dotfiles.maps')
require('dotfiles.commands')

-- Code completion
o.pumheight = 30
o.completeopt = 'menu'
o.complete = { '.', 'b' }

-- Generic
o.colorcolumn = '80'
o.number = true
o.relativenumber = true
o.ruler = false
o.signcolumn = 'yes'
o.synmaxcol = 256
o.termguicolors = true
o.textwidth = 80
o.wrap = false
o.linebreak = true
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
o.showmode = false
o.pastetoggle = '<F2>'
o.splitright = true
o.title = false
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

o.regexpengine = 0
o.list = true
o.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
o.winheight = 5
o.path = '.,,'

-- GUI
do
  local font = 'Source Code Pro'
  local size = '8'

  o.guifont = font .. ':h' .. size
  o.guifontwide = 'Noto Color Emoji:h' .. size
  o.linespace = 0

  if fn['exists']('g:GtkGuiLoaded') == 1 then
    fn['rpcnotify'](1, 'Gui', 'Font', font .. ' ' .. size)
    fn['rpcnotify'](1, 'Gui', 'Linespace', '0')
    fn['rpcnotify'](1, 'Gui', 'Option', 'Popupmenu', 0)
    fn['rpcnotify'](1, 'Gui', 'Option', 'Tabline', 0)
    fn['rpcnotify'](1, 'Gui', 'Command', 'SetCursorBlink', '0')
  end
end

-- Indentation
o.expandtab = true
o.shiftwidth = 4
o.shiftround = true
o.softtabstop = 4
o.tabstop = 4

-- Markdown
g.markdown_fenced_languages = { 'ruby', 'rust', 'sql', 'inko', 'yaml' }

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
o.ignorecase = true
o.smartcase = true

-- Statuscolumn
o.statuscolumn = '%s%=%{v:relnum?v:relnum:v:lnum} %#FoldColumn#▏%*'

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
