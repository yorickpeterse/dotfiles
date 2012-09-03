" General settings
set nocompatible
set textwidth=79
set number
set backspace=indent,eol,start
set omnifunc=syntaxcomplete#Complete
set nowrap
set backupskip=/tmp/*,/private/tmp/*
set clipboard=unnamed
set pastetoggle=<F2>
set mouse=a

" colorcolumn doesn't work on slightly older versions of Vim.
if version >= 703
  set colorcolumn=79
endif

" Printer options
set printoptions=number:n
set printoptions=header:0

" Allow per directory .vimrc files
set exrc
set secure

" Enable Pathogen
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()

" Settings for Syntastic.
set statusline=\ \"%t\"\ %y\ %m%#warningmsg#%{SyntasticStatuslineFlag()}%*
let g:syntastic_auto_loc_list       = 0
let g:syntastic_stl_format          = '[%E{Errors: %e, line %fe}%B{ | }'
let g:syntastic_stl_format         .= '%W{Warnings: %w, line %fw}]'
let g:syntastic_c_no_include_search = 1
let g:syntastic_c_compiler_options  = ' -Wextra -Wall -pedantic'
let g:syntastic_c_remove_include_errors = 1

" Ignore syntax checking for Shell scripts as this is currently broken.
let g:syntastic_mode_map = {'mode': 'active', 'passive_filetypes': ['sh']}

" Font settings.
if has('gui_gtk2')
  set guifont=Inconsolata\ Medium\ 11
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
let NERDTreeIgnore        = ['\.pyc$', '__pycache__']

function! Trim()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//eg
  call cursor(l, c)
:endfunction

" Function that switches Vim into "Email" mode allowing me to write nicely
" aligned Emails in Vim.
function! Email()
  set ft=mail
  set colorcolumn=72
  set textwidth=72
:endfunction

" Switches Vim back to normal mode.
function! Normal()
  set colorcolumn=79
  set textwidth=79
:endfunction

" Converts the file encoding to UTF-8. Using iconv for this doesn't always
" work, Vim for some reason does (it's magic!).
function! ConvertEncoding()
  set fileencoding=utf-8
  write
:endfunction

" Automatically strip trailing whitespace.
autocmd! BufWritePre * :call Trim()

" Set a few filetypes for some uncommon extendsions
autocmd! BufRead,BufNewFile *.xhtml  set filetype=html
autocmd! BufRead,BufNewFile *.md     set filetype=markdown
autocmd! BufRead,BufNewFile Gemfile  set filetype=ruby
autocmd! BufRead,BufNewFile *.rake   set filetype=ruby
autocmd! BufRead,BufNewFile *.ru     set filetype=ruby
autocmd! BufRead,BufNewFile *        match Visual /\s\+$/

autocmd! FileType ruby setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType yaml setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType vim  setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab

" Use actual tabs instead of spaces for Perl and PHP.
autocmd! FileType perl setlocal shiftwidth=4 softtabstop=4 tabstop=4 noexpandtab
autocmd! FileType php  setlocal shiftwidth=4 softtabstop=4 tabstop=4 noexpandtab

" Custom key bindings
map <F3> :call Email()<CR><Esc>
map <F4> :call Normal()<CR><Esc>
map <F5> :Errors<CR><Esc>
map <F6> :call ConvertEncoding()<CR><Esc>

" Load a host specific .vimrc. This allows this generic .vimrc file to be
" re-used across the various machines that I use while still being able to set
" host specific configuration options.
"
" The name .hvimrc is derived from "host specific .vimrc".
if filereadable(expand('~/.hvimrc'))
  source ~/.hvimrc
endif
