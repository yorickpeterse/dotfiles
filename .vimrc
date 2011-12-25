" General settings
set nocompatible
set colorcolumn=80
set textwidth=80
set number
set backspace=indent,eol,start
set omnifunc=syntaxcomplete#Complete
set nowrap
set backupskip=/tmp/*,/private/tmp/*

" Printer options
set printoptions=number:n
set printoptions=header:0

" Allow per directory .vimrc files
set exrc
set secure

" Font settings. I use Monaco on Linux based systems and Consolas on
" others (Inconsolata doesn't render too well on Linux based OS').
if has('gui_gtk2')
  set guifont=Monaco\ 10
else
  set guifont=Consolas:h14
endif

filetype plugin indent on
syntax on
color autumn

" Indentation settings
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" Customize various key settings and commands.
let mapleader             = ','
let maplocalleader        = '\'
let g:user_zen_leader_key = '<c-e>'
let g:user_zen_settings   = {'indentation' : '    '}
let g:snips_author        = 'Yorick Peterse'
let NERDTreeShowBookmarks = 0

" Share the OS' clipboard with Vim.
set clipboard=unnamed

" Toggle paste mode
set pastetoggle=<F2>

" Enable Pathogen
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()

" Set a few filetypes for some uncommon extendsions
autocmd! BufRead,BufNewFile *.xhtml  set filetype=html
autocmd! BufRead,BufNewFile *.md     set filetype=markdown
autocmd! BufRead,BufNewFile Gemfile  set filetype=ruby
autocmd! BufRead,BufNewFile Isolate  set filetype=ruby
autocmd! BufRead,BufNewFile *.rake   set filetype=ruby
autocmd! BufRead,BufNewFile *.ru     set filetype=ruby

autocmd! FileType ruby setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType yaml setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab

" Use actual tabs instead of spaces for Perl and PHP.
autocmd! FileType perl setlocal shiftwidth=4 softtabstop=4 tabstop=4 noexpandtab
autocmd! FileType php  setlocal shiftwidth=4 softtabstop=4 tabstop=4 noexpandtab

" Show trailing whitespace
match Todo /\s\+$/

" Removes all trailing whitespace
function! Trim()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//eg
  call cursor(l, c)
:endfunction

autocmd! BufWritePre * :call Trim()
