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

" Font settings
set guifont=Consolas:h14

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

" Enable Pathogen
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()

" Set a few filetypes for some uncommon extendsions
autocmd! BufRead,BufNewFile *.xhtml  set filetype=html
autocmd! BufRead,BufNewFile *.md     set filetype=markdown
autocmd! BufRead,BufNewFile Gemfile  set filetype=ruby
autocmd! BufRead,BufNewFile Isolate  set filetype=ruby

" Special indentation settings for PHP and HTML
autocmd! FileType ruby     setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType lua      setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType textile  setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType markdown setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType rst      setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType yaml     setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType vim      setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab

autocmd! FileType perl     setlocal shiftwidth=4 softtabstop=4 tabstop=4 noexpandtab
autocmd! FileType php      setlocal shiftwidth=4 softtabstop=4 tabstop=4 noexpandtab

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
