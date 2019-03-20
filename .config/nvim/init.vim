" (Neo)Vim configuration

" Setting the Python 2/3 executables before loading plugins speeds up starting
" (Neo)Vim a bit.
let g:python3_host_prog = '/usr/bin/python'
let g:python_host_prog = '/usr/bin/python2'

" Plugins, loaded first so other settings can depend on them being present.
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
Plug 'racer-rust/vim-racer'
Plug 'ervandew/supertab'
Plug 'w0rp/ale'

call plug#end()

set backspace=indent,eol,start
set backupskip=/tmp/*
set clipboard=unnamed
set completeopt=menu
set diffopt=filler,vertical
set lz
set mouse=
set noshowcmd
set omnifunc=syntaxcomplete#Complete
set pastetoggle=<F2>
set splitright
set title
set pumheight=50

" Syntax settings
set colorcolumn=80
set noruler
set nowrap
set number
set relativenumber
set synmaxcol=256
set termguicolors
set textwidth=80

filetype plugin indent on
syntax on
color happy_hacking

" These settings are disabled to get some extra performance out of Vim when
" dealing with large files.
set nocursorcolumn
set nocursorline

" Indentation
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

autocmd! FileType ruby setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType eruby setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType yaml setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType coffee setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType haml setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType scss setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType rust setlocal tw=80

" Searching
set inccommand=nosplit
set incsearch
set nohlsearch

if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" Printer settings
set printoptions=number:n
set printoptions=header:0

" Tab and status lines
set guitablabel=%f
set statusline=%f\ %w%m%r

let mapleader = ','
let maplocalleader = '\'

" Deoplete
call deoplete#custom#option('ignore_sources', {
    \ '_': ['around', 'file', 'dictionary', 'tag'],
    \ 'rust': ['around', 'file', 'dictionary', 'tag', 'buffer']
    \ })

call deoplete#custom#source('_', 'disabled_syntaxes', ['Comment', 'String'])
call deoplete#custom#option('num_processes', 2)
call deoplete#custom#option('auto_complete_delay', 50)
call deoplete#custom#option('auto_refresh_delay', 200)
call deoplete#custom#option('max_list', 100)

let g:deoplete#enable_at_startup = 1
let g:racer_cmd = '/usr/bin/racer'

" UltiSnips
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

" netrw
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_winsize = 15
let g:netrw_altv = 1
let g:netrw_list_hide = ',^\.git,__pycache__,rustc-incremental,^tags$'

autocmd FileType netrw setlocal bufhidden=delete

" NERDCommenter
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

" Markdown
let g:markdown_fenced_languages = ['ruby', 'rust', 'sql', 'inko', 'yaml']

" FZF
let $FZF_DEFAULT_COMMAND = 'rg --files --follow'

let g:fzf_colors =
\ { 'fg': ['fg', 'Normal'],
  \ 'bg': ['bg', 'Normal'],
  \ 'hl': ['fg', 'Comment'],
  \ 'fg+': ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+': ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+': ['fg', 'Notice'],
  \ 'info': ['fg', 'PreProc'],
  \ 'prompt': ['fg', 'Comment'],
  \ 'pointer': ['fg', 'Normal'],
  \ 'marker': ['fg', 'Normal'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header': ['fg', 'Comment'] }

function! s:fzf_statusline()
  setlocal nonumber
  setlocal norelativenumber
  setlocal statusline=FZF
endfunction

autocmd! User FzfStatusLine call <SID>fzf_statusline()

map <leader>f :call fzf#vim#files('.', {'options': '--prompt ">> " --exact'})<CR>
map <leader>t :call fzf#vim#buffer_tags('', {'options': '--prompt ">> " --no-reverse --no-sort --exact'})<CR>
map <leader>b :call fzf#vim#buffers('', {'options': '--prompt ">> " --no-reverse --exact'})<CR>
map <leader>l :call fzf#vim#buffer_lines('', {'options': '--prompt ">> " --no-reverse --no-sort --exact'})<CR>

command! -bang -nargs=* Rg
    \ call fzf#vim#grep('rg --column --line-number --no-heading
    \ --color=always --smart-case
    \ --colors match:fg:yellow
    \ --colors match:style:bold
    \ --colors path:fg:blue
    \ --colors path:style:bold
    \ --colors column:fg:cyan
    \ --colors line:fg:cyan '.shellescape(<q-args>), 1, <bang>0)

" Supertab
let g:SuperTabDefaultCompletionType = '<c-n>'

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

" Automatically strip trailing whitespace.
function! Trim()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//eg
  call cursor(l, c)
endfunction

autocmd! BufWritePre * :call Trim()

" File type detection
autocmd! BufRead,BufNewFile *.md     set filetype=markdown
autocmd! BufRead,BufNewFile Gemfile  set filetype=ruby
autocmd! BufRead,BufNewFile *.rake   set filetype=ruby
autocmd! BufRead,BufNewFile *.ru     set filetype=ruby
autocmd! BufRead,BufNewFile *.rs     set filetype=rust
autocmd! BufRead,BufNewFile *.rll    set filetype=rll
autocmd! BufRead,BufNewFile Dangerfile set filetype=ruby

" Highlight trailing whitespace
autocmd BufWinEnter * match Visual /\s\+$/
autocmd InsertEnter * match Visual /\s\+\%#\@<!$/
autocmd InsertLeave * match Visual /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Key bindings
map <F6> :Lexplore<CR><Esc>

" Disabled since I press it by accident way too often.
map K <nop>

" Disable the scroll wheel to force the use of Vim motions.
map <ScrollWheelUp> <nop>
map <S-ScrollWheelUp> <nop>
map <ScrollWheelDown> <nop>
map <S-ScrollWheelDown> <nop>
map <ScrollWheelLeft> <nop>
map <S-ScrollWheelLeft> <nop>
map <ScrollWheelRight> <nop>
map <S-ScrollWheelRight> <nop>

" NeoVim terminals

" use Control + ] to exit insert mode in a terminal, allowing any nested Neovim
" instances to still use Control + [.
tnoremap <C-]> <C-\><C-n>

" Allow Control + b + {h,j,k,l} to navigate around buffers even when inside a
" terminal, removing the need for exiting insert mode.
tnoremap <C-b>h <C-\><C-n><C-w>hi
tnoremap <C-b>j <C-\><C-n><C-w>ji
tnoremap <C-b>k <C-\><C-n><C-w>ki
tnoremap <C-b>l <C-\><C-n><C-w>li

function! s:openTerm(cmd)
  exec a:cmd

  " For reasons unknown, the terminal always starts in $HOME since nvim 0.3.4-ish.
  call termopen($SHELL . " -C 'cd " . getcwd() . "'")
  setlocal nonumber nornu
  startinsert
endfunction

command! Term call s:openTerm('new')
command! Vterm call s:openTerm('vnew')
command! Tterm call s:openTerm('tabnew')
