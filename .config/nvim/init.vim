" ============================================================================
" VIM CONFIGURATION FILE
"
" This file contains all the Vim configuration settings that I use across
" different computers. These settings include setting themes, remapping leader
" keys, callbacks and many other settings. Font related settings are set in
" ~/.hvimrc instead since different setups tend to render fonts completely
" different (at least in my experience).
"
" The code in this configuration file is released in the public domain. You're
" free to use it as you see fit.
"
" Author:  Yorick Peterse
" Website: http://yorickpeterse.com/
" License: Public Domain

" ============================================================================
" GENERAL SETTINGS
"
" A collection of general Vim settings such as enabling the use of the mouse,
" what key combination to use for toggling the paste mode and various other
" settings.
"
set backspace=indent,eol,start
set omnifunc=syntaxcomplete#Complete
set backupskip=/tmp/*
set clipboard=unnamed
set pastetoggle=<F2>
set mouse=a
set guitablabel=%f

set nohlsearch
set noincsearch
set title

" Printer settings
set printoptions=number:n
set printoptions=header:0

let mapleader      = ','
let maplocalleader = '\'

" These settings are disabled to get some extra performance out of Vim when
" dealing with large files.
set nocursorcolumn
set nocursorline

" Use ag for the :grep command as well as for Ctrlp
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor

  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

" ============================================================================
" PLUGIN SETTINGS
"

let g:plug_url_format = 'git@github.com:%s.git'

call plug#begin('~/.vim/plugged')

Plug 'editorconfig/editorconfig-vim'
Plug 'godlygeek/tabular'
Plug 'kien/ctrlp.vim'
Plug 'pangloss/vim-javascript'
Plug 'Raimondi/delimitMate'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'neomake/neomake'
Plug 'SirVer/ultisnips'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-haml'
Plug 'dag/vim-fish'
Plug '~/.vim/plugged/aeon.vim'
Plug 'YorickPeterse/happy_hacking.vim'

call plug#end()

" ctrl-p
let g:ctrlp_custom_ignore = {'dir': '\v[\/]\.(git|hg|svn|staging)$'}

" UltiSnips settings.
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" NERDTree settings.
let NERDTreeShowBookmarks = 0
let NERDTreeIgnore        = ['\.pyc$', '\.pyo$', '__pycache__', '\.o$', 'rustc-incremental']
let NERDTreeWinSize       = 25

" Neomake
let g:neomake_error_sign = {'text': '❌', 'texthl': 'NeomakeErrorSign'}
let g:neomake_warning_sign = {'text': '❗', 'texthl': 'NeomakeWarningSign'}
let g:neomake_message_sign = {'text': '●', 'texthl': 'NeomakeMessageSign'}
let g:neomake_info_sign = {'text': '🛈', 'texthl': 'NeomakeInfoSign'}

" rust.vim
let g:rustfmt_fail_silently = 1
let g:rustfmt_autosave = 1

" ============================================================================
" SYNTAX SETTINGS
"
" Settings related to configuring the syntax features of Vim such as the text
" width, what theme to use and so on.
"
set textwidth=80
set nowrap
set number
set synmaxcol=256
set diffopt=filler,vertical
filetype plugin indent on
syntax on
color happy_hacking

" Enable true colors in terminals, even in Tmux
set termguicolors

" colorcolumn doesn't work on slightly older versions of Vim.
if version >= 703
  set colorcolumn=80
endif

" Indentation settings
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" ============================================================================
" CUSTOM FUNCTIONS
"
" A collection of custom functions such as a function used for trimming
" trailing whitespace or converting a file's encoding to UTF-8.

" Removes trailing whitespace from the current buffer.
function! Trim()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//eg
  call cursor(l, c)
:endfunction

" ============================================================================
" HOOKS
"
" Collection of various hooks that have to be executed when a certain filetype
" is set or action is executed.

" Automatically strip trailing whitespace.
autocmd! BufWritePre * :call Trim()
autocmd! BufWritePost * Neomake

" Set a few filetypes for some uncommon extensions
autocmd! BufRead,BufNewFile *.md     set filetype=markdown
autocmd! BufRead,BufNewFile Gemfile  set filetype=ruby
autocmd! BufRead,BufNewFile *.rake   set filetype=ruby
autocmd! BufRead,BufNewFile *.ru     set filetype=ruby
autocmd! BufRead,BufNewFile *.rs     set filetype=rust
autocmd! BufRead,BufNewFile *.rll    set filetype=rll

" Taken from http://vim.wikia.com/wiki/Highlight_unwanted_spaces
autocmd BufWinEnter * match Visual /\s\+$/
autocmd InsertEnter * match Visual /\s\+\%#\@<!$/
autocmd InsertLeave * match Visual /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Use 2 spaces per indentation level for Ruby, YAML and Vim script.
autocmd! FileType ruby   setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType eruby  setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType yaml   setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType coffee setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType haml   setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType rust   setlocal tw=80

" ============================================================================
" KEY BINDINGS
"
" A collection of custom key bindings.
"
nmap <leader>l :call ToggleLineNumbers()<CR>
map <F6> :NERDTreeToggle<CR><Esc>

" I press this combination so often by accident it's really annoying, I have no
" need for it so go away.
map K <nop>

" Using the scroll wheel makes my shoulder cry out in pain.
map <ScrollWheelUp> <nop>
map <S-ScrollWheelUp> <nop>
map <ScrollWheelDown> <nop>
map <S-ScrollWheelDown> <nop>
map <ScrollWheelLeft> <nop>
map <S-ScrollWheelLeft> <nop>
map <ScrollWheelRight> <nop>
map <S-ScrollWheelRight> <nop>
