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
set guitablabel=%f
set statusline=%f\ %w%m%r
set splitright
set noshowcmd
set noruler

" Disable the mouse to force myself to not use it.
set mouse=

set nohlsearch
set incsearch
set title
set inccommand=nosplit

" Printer settings
set printoptions=number:n
set printoptions=header:0

let mapleader      = ','
let maplocalleader = '\'

" These settings are disabled to get some extra performance out of Vim when
" dealing with large files.
set nocursorcolumn
set nocursorline

if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" ============================================================================
" PLUGIN SETTINGS
"

let g:plug_url_format = 'git@github.com:%s.git'

call plug#begin('~/.vim/plugged')

Plug 'jiangmiao/auto-pairs'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'SirVer/ultisnips'
Plug 'tpope/vim-fugitive'
Plug 'dag/vim-fish'
Plug 'git@gitlab.com:inko-lang/inko.vim.git'
Plug 'git@gitlab.com:yorickpeterse/happy_hacking.vim.git'
Plug 'ludovicchabant/vim-gutentags'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'sebastianmarkow/deoplete-rust'
Plug 'ervandew/supertab'
Plug 'w0rp/ale'

call plug#end()

" Deoplete settings
set completeopt=menu

call deoplete#custom#option('ignore_sources', { '_': ['around', 'file', 'dictionary', 'tag'] })
call deoplete#custom#source('_', 'disabled_syntaxes', ['Comment', 'String'])
call deoplete#custom#option('num_processes', 2)
call deoplete#custom#option('auto_refresh_delay', 100)

let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#rust#racer_binary = '/usr/bin/racer'
let g:deoplete#sources#rust#rust_source_path = '/home/yorickpeterse/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src'

autocmd! FileType gitcommit
    \ call deoplete#custom#buffer_option('auto_complete', v:false)

autocmd! FileType markdown
    \ call deoplete#custom#buffer_option('auto_complete', v:false)

" UltiSnips settings.
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" netrw settings
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_winsize = 15
let g:netrw_altv = 1
let g:netrw_list_hide = netrw_gitignore#Hide()
    \ . ',^\.git,__pycache__,rustc-incremental,^tags$'

autocmd FileType netrw setlocal bufhidden=delete

" NERDCommenter settings
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCustomDelimiters = { 'inko': { 'left': '#' } }

" ALE
let g:ale_sign_error = '✖'
let g:ale_sign_warning = '●'
let g:ale_virtualtext_cursor = 0
let g:ale_lint_on_enter = 1
let g:ale_echo_msg_format = '[%linter%]: %s'
let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 0

" delimitMate
let delimitMate_expand_cr = 1

" gutentags
let g:gutentags_ctags_exclude = ['target', 'tmp', 'spec', 'node_modules', 'public', '*.json', '*.svg']

" FZF
let $FZF_DEFAULT_COMMAND = 'rg --files --follow'

" Markdown settings
let g:markdown_fenced_languages = ['ruby', 'rust', 'sql', 'inko', 'yaml']

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Notice'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'prompt':  ['fg', 'Comment'],
  \ 'pointer': ['fg', 'Normal'],
  \ 'marker':  ['fg', 'Normal'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

function! s:fzf_statusline()
  setlocal nonumber
  setlocal norelativenumber
  setlocal statusline=FZF
endfunction

autocmd! User FzfStatusLine call <SID>fzf_statusline()

" Supertab
let g:SuperTabDefaultCompletionType = "<c-n>"

" Tabline
function! Tabline()
  let s = ''
  for i in range(tabpagenr('$'))
    let tab = i + 1
    let winnr = tabpagewinnr(tab)
    let buflist = tabpagebuflist(tab)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)
    let bufmodified = getbufvar(bufnr, "&mod")

    let s .= '%' . tab . 'T'
    let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let s .= ' ' . tab .': '
    let s .= (bufname != '' ? fnamemodify(bufname, ':t') . ' ' : '[No Name] ')

    if bufmodified
      let s .= '[+] '
    endif
  endfor

  let s .= '%#TabLineFill#'
  return s
endfunction
set tabline=%!Tabline()

" ============================================================================
" SYNTAX SETTINGS
"
" Settings related to configuring the syntax features of Vim such as the text
" width, what theme to use and so on.
"
set textwidth=80
set colorcolumn=80
set nowrap
set lz
set number
set synmaxcol=256
set diffopt=filler,vertical
filetype plugin indent on
syntax on
color happy_hacking

" Enable true colors in terminals, even in Tmux
set termguicolors

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
endfunction

function! s:openTerm(vertical)
  let cmd = a:vertical ? 'vnew' : 'new'
  exec cmd
  term
  setlocal nonumber nornu
  startinsert
endfunction

" ============================================================================
" HOOKS
"
" Collection of various hooks that have to be executed when a certain filetype
" is set or action is executed.

" Automatically strip trailing whitespace.
autocmd! BufWritePre * :call Trim()

" Set a few filetypes for some uncommon extensions
autocmd! BufRead,BufNewFile *.md     set filetype=markdown
autocmd! BufRead,BufNewFile Gemfile  set filetype=ruby
autocmd! BufRead,BufNewFile *.rake   set filetype=ruby
autocmd! BufRead,BufNewFile *.ru     set filetype=ruby
autocmd! BufRead,BufNewFile *.rs     set filetype=rust
autocmd! BufRead,BufNewFile *.rll    set filetype=rll
autocmd! BufRead,BufNewFile Dangerfile set filetype=ruby

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
autocmd! FileType scss   setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType rust   setlocal tw=80

" ============================================================================
" KEY BINDINGS
"
" A collection of custom key bindings.
"
map <F6> :Lexplore<CR><Esc>

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

" FZF
map <leader>f :call fzf#vim#files('.', {'options': '--prompt ">> "'})<CR>
map <leader>t :call fzf#vim#buffer_tags('', {'options': '--prompt ">> " --no-reverse'})<CR>
map <leader>b :call fzf#vim#buffers('', {'options': '--prompt ">> " --no-reverse'})<CR>
map <leader>l :call fzf#vim#buffer_lines('', {'options': '--prompt ">> " --no-reverse'})<CR>

command! -bang -nargs=* Rg
    \ call fzf#vim#grep('rg --column --line-number --no-heading
    \ --color=always --smart-case
    \ --colors match:fg:yellow
    \ --colors match:style:bold
    \ --colors path:fg:blue
    \ --colors path:style:bold
    \ --colors column:fg:cyan
    \ --colors line:fg:cyan '.shellescape(<q-args>), 1, <bang>0)

" Neovim terminals

" use Control + ] to exit insert mode in a terminal, allowing any nested Neovim
" instances to still use Control + [.
tnoremap <C-]> <C-\><C-n>

" Allow Control + b + {h,j,k,l} to navigate around buffers even when inside a
" terminal, removing the need for exiting insert mode.
tnoremap <C-b>h <C-\><C-n><C-w>hi
tnoremap <C-b>j <C-\><C-n><C-w>ji
tnoremap <C-b>k <C-\><C-n><C-w>ki
tnoremap <C-b>l <C-\><C-n><C-w>li

command! Term call s:openTerm(0)
command! Vterm call s:openTerm(1)
