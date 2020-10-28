" (Neo)Vim configuration

" Python settings {{{1
" These are set before loading plugins to speeds up starting (Neo)Vim a bit.
let g:python3_host_prog = '/usr/bin/python'
let g:python_host_prog = '/usr/bin/python2'

" Plugins {{{1
let g:plug_url_format = 'git@github.com:%s.git'

call plug#begin('~/.config/nvim/plugged')

Plug 'Krasjet/auto.pairs'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'SirVer/ultisnips'
Plug 'tpope/vim-fugitive'
Plug 'dag/vim-fish'
Plug 'git@gitlab.com:inko-lang/inko.vim.git'
Plug 'git@gitlab.com:yorickpeterse/vim-paper.git'
Plug 'ludovicchabant/vim-gutentags'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', { 'branch': 'master', 'do': 'yarn install --frozen-lockfile' }
Plug 'neoclide/jsonc.vim'
Plug 'dense-analysis/ale'
Plug 'lifepillar/vim-colortemplate'
Plug 'editorconfig/editorconfig-vim'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'yssl/QFEnter'

call plug#end()

" Generic settings {{{1
set backspace=indent,eol,start
set backupskip=/tmp/*
set clipboard=unnamed
set completeopt=menu
set complete=.,b
set diffopt=filler,vertical,internal,algorithm:histogram,indent-heuristic
set lz
set noshowcmd
set omnifunc=syntaxcomplete#Complete
set pastetoggle=<F2>
set splitright
set title
set pumheight=30
set mouse=
set shortmess=atOIc
set signcolumn=yes
set colorcolumn=80
set noruler
set nowrap
set number
set relativenumber
set synmaxcol=256
set termguicolors
set textwidth=80
set guitablabel=%f
set inccommand=nosplit
set incsearch
set nohlsearch
set scrollback=1000

set grepprg=rg\ --vimgrep
set grepformat=%f:%l:%c:%m,%f:%l:%m

set printoptions=number:n
set printoptions=header:0

let mapleader = ','
let maplocalleader = '\'

" The NFA engine is rather slow, especially for large Ruby files. After testing
" this extensively, I found that switching to the old engine can reduce input
" latency by about 40%.
set regexpengine=1

filetype plugin indent on
syntax on
color paper

" These settings are disabled to get some extra performance out of Vim when
" dealing with large files.
set nocursorcolumn
set nocursorline

" Open the quickfix window at the bottom of all other windows.
autocmd FileType qf wincmd J

" Indentation settings {{{1
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
autocmd! FileType vim setlocal sw=2 sts=2 ts=2 expandtab
autocmd! FileType rust setlocal tw=80

" Tab and status lines {{{1
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

function! AleWarnings() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:errors = l:counts.error + l:counts.style_error
  let l:warnings = l:counts.total - l:errors

  if l:warnings > 0
    return printf("\u2002W: %d\u2002", warnings)
  endif

  return ''
endfunction

function! AleErrors() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:errors = l:counts.error + l:counts.style_error

  if l:errors > 0
    return printf("\u2002E: %d\u2002", errors)
  endif

  return ''
endfunction

set statusline=%f\ %w%m%r%=
set statusline+=%#WhiteOnYellow#%{AleWarnings()}%*
set statusline+=%#WhiteOnRed#%{AleErrors()}%*

" UltiSnips {{{1
let g:UltiSnipsExpandTrigger = '<C-s>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

" This disables UltiSnips' auto trigger feature, which can easily consume
" between 10% and 20% of a CPU core when typing in insert mode.
augroup ultisnips_no_auto_expansion
  au!
  au VimEnter * au! UltiSnips_AutoTrigger
augroup END

" netrw {{{1
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_winsize = 15
let g:netrw_altv = 1
let g:netrw_list_hide = ',^\.git,__pycache__,rustc-incremental,^tags$'

autocmd FileType netrw setlocal bufhidden=delete

" NERDCommenter {{{1
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCustomDelimiters = { 'inko': { 'left': '#' } }

" auto-pairs
let g:AutoPairsOpenBalanceBlacklist = ['{']

" ALE {{{1
let g:ale_disable_lsp = 1
let g:ale_sign_error = '✖'
let g:ale_sign_warning = '●'
let g:ale_virtualtext_cursor = 0
let g:ale_echo_msg_format = '[%linter%]: %s'
let g:ale_lint_on_enter = 1
let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_linters = {
  \ 'rust': [],
  \ 'ruby': ['ruby', 'rubocop'],
  \ 'python': ['flake8'],
  \ 'markdown': ['vale']
  \ }

let g:ale_fixers = {
  \ 'rust': 'rustfmt',
  \ 'javascript': 'prettier'
  \ }

let g:ale_python_flake8_auto_pipenv = 1

" CoC
let g:coc_enable_locationlist = 0

" Use the location list for Coc, instead of its own (somewhat confusing to use)
" location list system.
autocmd! User CocLocationsChange call setloclist(0, g:coc_jump_locations) | lwindow

let g:coc_global_extensions = [
  \ "coc-json",
  \ "coc-tsserver",
  \ "coc-rust-analyzer",
  \ "coc-ultisnips",
  \ "coc-jedi"
  \ ]

" gutentags {{{1
let g:gutentags_ctags_exclude = ['target', 'tmp', 'spec', 'node_modules', 'public', '*.json', '*.svg']
let g:gutentags_file_list_command = 'rg --files'

" Markdown {{{1
let g:markdown_fenced_languages = ['ruby', 'rust', 'sql', 'inko', 'yaml']

" Fugitive {{{1
let g:fugitive_dynamic_colors = 0

" FZF {{{1
let $FZF_DEFAULT_COMMAND = 'rg --files --follow'

let g:fzf_colors = {
  \ 'fg': ['fg', 'Normal'],
  \ 'fg+': ['fg', 'Normal'],
  \ 'bg': ['bg', 'Normal'],
  \ 'bg+': ['bg', 'Cursor'],
  \ 'hl': ['fg', 'Search'],
  \ 'hl+': ['fg', 'Search'],
  \ 'info': ['fg', 'Number'],
  \ 'gutter': ['bg', 'Normal'],
  \ 'prompt': ['fg', 'Normal'],
  \ 'pointer': ['fg', 'Normal'],
  \ 'marker': ['fg', 'Normal'],
  \ 'spinner': ['fg', 'Normal'],
  \ 'header': ['fg', 'Comment'],
  \ }

let g:fzf_layout = {
  \ 'window': {
  \   'width': 0.7,
  \   'height': 0.6,
  \   'border': 'sharp',
  \   'highlight': 'VertSplit'
  \ }
  \ }

let g:fzf_preview_window = ''

function! s:FZFStatusLine()
  setlocal nonumber
  setlocal norelativenumber
  setlocal statusline=FZF
  setlocal signcolumn=no
  silent file FZF
endfunction

autocmd! User FzfStatusLine call <SID>FZFStatusLine()

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(
  \   <q-args>,
  \   {'options': ['--prompt=>> ', '--reverse', '--exact']},
  \   <bang>0
  \ )

command! -bang -nargs=* BTags
  \ call fzf#vim#buffer_tags(
  \   <q-args>,
  \   {
  \     'placeholder': '{2}:{3}',
  \     'options': ['--prompt=>> ', '--reverse', '--no-sort', '--exact']
  \   },
  \   <bang>0
  \ )

command! -bar -bang -nargs=? -complete=buffer Buffers
  \ call fzf#vim#buffers(
  \   <q-args>,
  \   {
  \     'placeholder': '{1}',
  \     'options': ['--prompt=>> ', '--reverse', '--exact']
  \   },
  \   <bang>0
  \ )

command! -bang -nargs=* BLines
  \ call fzf#vim#buffer_lines(
  \   <q-args>,
  \   {'options': ['--prompt=>> ', '--reverse', '--no-sort', '--exact']},
  \   <bang>0
  \ )

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading
  \     --color=always --smart-case
  \     --colors match:none
  \     --colors match:fg:yellow
  \     --colors match:style:bold
  \     --colors match:style:underline
  \     --colors path:none
  \     --colors path:style:bold
  \     --colors column:none
  \     --colors line:fg:blue '.shellescape(<q-args>),
  \   1,
  \   <bang>0
  \ )

" Trailing whitespace {{{1
function! Trim()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//eg
  call cursor(l, c)
endfunction

autocmd! BufWritePre * :call Trim()
autocmd! BufWinEnter * match Visual /\s\+$/
autocmd! InsertEnter * match Visual /\s\+\%#\@<!$/
autocmd! InsertLeave * match Visual /\s\+$/
autocmd! BufWinLeave * call clearmatches()

" File type detection {{{1
autocmd! BufRead,BufNewFile *.rll set filetype=rll
autocmd! BufRead,BufNewFile Dangerfile set filetype=ruby

" Mappings {{{1
map <silent> <leader>f :Files<CR>
map <silent> <leader>t :BTags<CR>
map <silent> <leader>b :Buffers<CR>
map <silent> <leader>l :BLines<CR>
map <F6> :Lexplore<CR><Esc>
map K <nop>
map <ScrollWheelUp> <nop>
map <S-ScrollWheelUp> <nop>
map <ScrollWheelDown> <nop>
map <S-ScrollWheelDown> <nop>
map <ScrollWheelLeft> <nop>
map <S-ScrollWheelLeft> <nop>
map <ScrollWheelRight> <nop>
map <S-ScrollWheelRight> <nop>

" Custom mappings for Fugitive
map <silent> <leader>gs :vert bo Gstatus<CR>
map <silent> <leader>gc :vert bo Gcommit<CR>
map <silent> <leader>gd :Gdiff<CR>

" Mappings for CoC
map <silent> <leader>h :call CocActionAsync('doHover')<CR>
map <silent> <leader>r <Plug>(coc-rename)
map <silent> <leader>d <Plug>(coc-definition)
map <silent> <leader>i <Plug>(coc-references)

" Confirm completion by pressing enter
inoremap <silent><expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Support exiting terminal INSERT mode using C-[ and C-]. C-] is mapped so we
" can still exist in nested Vim sessions.
tnoremap <C-[> <C-\><C-n>
tnoremap <C-]> <C-\><C-n>

" Allow Control + b + {h,j,k,l} to navigate around buffers even when inside a
" terminal, removing the need for exiting insert mode.
tnoremap <C-b>h <C-\><C-n><C-w>hi
tnoremap <C-b>j <C-\><C-n><C-w>ji
tnoremap <C-b>k <C-\><C-n><C-w>ki
tnoremap <C-b>l <C-\><C-n><C-w>li

" Allow Control C and V for copying and pasting, mostly to make this easier in
" Vim terminals.
noremap <C-c> "+y
inoremap <C-v> <Esc>"+pa

" This allows cycling through popup menu results using tab, as well as
" performing keyword completion if the menu is not visible.
function! s:checkBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <tab>
  \ pumvisible() ? "\<C-n>" :
  \ coc#jumpable() ? "\<C-r>=coc#rpc#request('snippetNext',[])\<CR>" :
  \ <SID>checkBackSpace() ? "\<tab>" :
  \ coc#refresh()

inoremap <silent><expr> <S-tab>
  \ pumvisible() ? "\<C-p>" :
  \ coc#jumpable() ? "\<C-r>=coc#rpc#request('snippetPrev',[])\<CR>" :
  \ "\<S-tab>"

" Custom commands {{{1
function! s:openTerm(cmd)
  exec a:cmd
  term
  setlocal nonumber nornu
  setlocal signcolumn=no
  startinsert
endfunction

command! Term call s:openTerm('new')
command! Vterm call s:openTerm('vnew')
command! Tterm call s:openTerm('tabnew')

" vim: fdm=marker
