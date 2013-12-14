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
set backupskip=/tmp/*
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

" These settings are disabled to get some extra performance out of Vim when
" dealing with large files.
set nocursorcolumn
set nocursorline

" I've disabled parens matching since it usually slows down drawing of
" characters quite a bit and I hardly rely on it anyway.
let loaded_matchparen = 1

" ============================================================================
" PLUGIN SETTINGS
"
" Settings for various plugins such as Pathogen and Syntastic.
"

runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()

" Syntastic settings.
let g:syntastic_auto_loc_list  = 0
let g:syntastic_stl_format     = '[%E{Errors: %e, line %fe}%B{ | }'
let g:syntastic_stl_format    .= '%W{Warnings: %w, line %fw}]'

let g:syntastic_c_check_header          = 0
let g:syntastic_c_compiler_options      = ' -Wextra -Wall'
let g:syntastic_c_remove_include_errors = 1

let g:syntastic_cpp_compiler_options   = ' -Wextra -Wall -std=c++0x'
let g:syntastic_javascript_jshint_conf = '/home/yorickpeterse/.jshint'

set statusline=\ \"%t\"\ %y\ %m%#warningmsg#%{SyntasticStatuslineFlag()}%*

" Ignore syntax checking for Shell scripts as this is currently broken.
let g:syntastic_mode_map = {
  \ 'mode': 'passive',
  \ 'active_filetypes': ['c', 'javascript', 'coffee', 'cpp']}

" snipMate settings.
let g:snips_author = 'Yorick Peterse'

" NERDTree settings.
let NERDTreeShowBookmarks = 0
let NERDTreeIgnore        = ['\.pyc$', '\.pyo$', '__pycache__']

" ============================================================================
" SYNTAX SETTINGS
"
" Settings related to configuring the syntax features of Vim such as the text
" width, what theme to use and so on.
"
set textwidth=79
set nowrap
set number
set synmaxcol=256
filetype plugin indent on
syntax on
color happy_hacking

" colorcolumn doesn't work on slightly older versions of Vim.
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

" Shows the syntax group name of the element under the cursor. Taken from the
" following Wiki page:
" http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
function! ShowSyntax()
  :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
  \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
  \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"
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
autocmd! BufRead,BufNewFile *.md     set filetype=markdown
autocmd! BufRead,BufNewFile Gemfile  set filetype=ruby
autocmd! BufRead,BufNewFile *.rake   set filetype=ruby
autocmd! BufRead,BufNewFile *.ru     set filetype=ruby

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

" ============================================================================
" KEY BINDINGS
"
" A collection of custom key bindings.
"
map <F5> :SyntasticCheck<CR><Esc>
map <F6> :NERDTreeToggle<CR><Esc>
map <F10> :call ShowSyntax()<CR><Esc>

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
