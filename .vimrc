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
set nocompatible
set backspace=indent,eol,start
set omnifunc=syntaxcomplete#Complete
set backupskip=/tmp/*,/private/tmp/*
set clipboard=unnamed
set pastetoggle=<F2>
set mouse=a
set tabline=%f
set guitablabel=%f

" Printer settings
set printoptions=number:n
set printoptions=header:0

let mapleader      = ','
let maplocalleader = '\'

" Allow per directory .vimrc files. These files can be used to set project
" specific configuration options.
set exrc
set secure

" ============================================================================
" PLUGIN SETTINGS
"
" Settings for various plugins such as Pathogen and Syntastic.
"

runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()

" Syntastic settings.
let g:syntastic_auto_loc_list       = 0
let g:syntastic_stl_format          = '[%E{Errors: %e, line %fe}%B{ | }'
let g:syntastic_stl_format         .= '%W{Warnings: %w, line %fw}]'

let g:syntastic_c_no_include_search     = 1
let g:syntastic_c_compiler_options      = ' -Wextra -Wall -pedantic -std=c++0x'
let g:syntastic_c_remove_include_errors = 1

let g:syntastic_cpp_compiler_options   = ' -Wextra -Wall -pedantic -std=c++0x'
let g:syntastic_javascript_jshint_conf = '/home/yorickpeterse/.jshint'

set statusline=\ \"%t\"\ %y\ %m%#warningmsg#%{SyntasticStatuslineFlag()}%*

" Ignore syntax checking for Shell scripts as this is currently broken.
let g:syntastic_mode_map = {'mode': 'active', 'passive_filetypes': ['sh']}

" Zencoding settings.
let g:user_zen_leader_key = '<c-e>'
let g:user_zen_settings   = {'indentation' : '    '}

" snipMate settings.
let g:snips_author = 'Yorick Peterse'

" NERDTree settings.
let NERDTreeShowBookmarks = 0
let NERDTreeIgnore        = ['\.pyc$', '__pycache__']

" ============================================================================
" SYNTAX SETTINGS
"
" Settings related to configuring the syntax features of Vim such as the text
" width, what theme to use and so on.
"
set textwidth=79
set nowrap
set number
filetype plugin indent on
syntax on
color autumn

" colorcolumn doesn't work on slightly older versions of Vim (7.0.3 is commonly
" used on Ubuntu machines).
if version >= 703
  set colorcolumn=79
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
"

" Removes trailing whitespace from the current buffer.
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

" ============================================================================
" HOOKS
"
" Collection of various hooks that have to be executed when a certain filetype
" is set or action is executed.
"

" Automatically strip trailing whitespace.
autocmd! BufWritePre * :call Trim()

" Set a few filetypes for some uncommon extendsions
autocmd! BufRead,BufNewFile *.xhtml  set filetype=html
autocmd! BufRead,BufNewFile *.md     set filetype=markdown
autocmd! BufRead,BufNewFile Gemfile  set filetype=ruby
autocmd! BufRead,BufNewFile *.rake   set filetype=ruby
autocmd! BufRead,BufNewFile *.ru     set filetype=ruby
autocmd! BufRead,BufNewFile *        match Visual /\s\+$/

" Use 2 spaces per indentation level for Ruby, YAML and Vim script.
autocmd! FileType ruby   setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType eruby  setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType coffee setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType haml   setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType yaml   setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
autocmd! FileType vim    setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab

" Use actual tabs instead of spaces for Perl and PHP.
autocmd! FileType perl setlocal shiftwidth=4 softtabstop=4 tabstop=4 noexpandtab
autocmd! FileType php  setlocal shiftwidth=4 softtabstop=4 tabstop=4 noexpandtab

" ============================================================================
" KEY BINDINGS
"
" A collection of custom key bindings.
"
map <F3> :call Email()<CR><Esc>
map <F4> :call Normal()<CR><Esc>
map <F5> :Errors<CR><Esc>
map <F6> :NERDTreeToggle<CR><Esc>

" ============================================================================
" HOST SPECIFIC CONFIGURATION
"
" Load a host specific .vimrc. This allows this generic .vimrc file to be
" re-used across the various machines that I use while still being able to set
" host specific configuration options.
"
" The name .hvimrc is derived from "host specific .vimrc".
"
if filereadable(expand('~/.hvimrc'))
  source ~/.hvimrc
endif
