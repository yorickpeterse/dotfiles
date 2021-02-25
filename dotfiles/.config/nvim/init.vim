" (Neo)Vim configuration

" Python settings {{{1
" These are set before loading plugins to speeds up starting (Neo)Vim a bit.
let g:python3_host_prog = '/usr/bin/python'
let g:python_host_prog = '/usr/bin/python2'

" Plugins {{{1
let g:plug_url_format = 'git@github.com:%s.git'

call plug#begin('~/.config/nvim/plugged')

Plug 'jiangmiao/auto-pairs'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'dag/vim-fish'
Plug 'git@gitlab.com:inko-lang/inko.vim.git'
Plug 'git@gitlab.com:yorickpeterse/vim-paper.git'
Plug 'ludovicchabant/vim-gutentags'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'dense-analysis/ale'
Plug 'lifepillar/vim-colortemplate'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'yssl/QFEnter'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/vim-vsnip'

call plug#end()

" Lua setup {{{1
lua require('dotfiles')

" Generic settings {{{1
set backspace=indent,eol,start
set backupskip=/tmp/*
set clipboard=unnamed
set completeopt=menu
set complete=.,b
set diffopt=filler,vertical,internal,algorithm:patience,indent-heuristic
set lz
set noshowcmd
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
set updatetime=1000

set grepprg=rg\ --vimgrep
set grepformat=%f:%l:%c:%m,%f:%l:%m

set printoptions=number:n
set printoptions=header:0

let mapleader = ','
let maplocalleader = '\'

" Some languages such as typescript are super slow using the old regex engine,
" so we use the new one.
set regexpengine=0

filetype plugin indent on
syntax on
color paper

" These settings are disabled to get some extra performance out of Vim when
" dealing with large files.
set nocursorcolumn
set nocursorline

" Indentation settings {{{1
set expandtab
set shiftwidth=4
set shiftround
set softtabstop=4
set tabstop=4

" Tab and status lines {{{1
function! init#Tabline()
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

set tabline=%!init#Tabline()

function! init#AleWarnings() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:errors = l:counts.error + l:counts.style_error
  let l:warnings = l:counts.total - l:errors

  if l:warnings > 0
    return printf("\u2002W: %d\u2002", warnings)
  endif

  return ''
endfunction

function! init#AleErrors() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:errors = l:counts.error + l:counts.style_error

  if l:errors > 0
    return printf("\u2002E: %d\u2002", errors)
  endif

  return ''
endfunction

set statusline=%f\ %w%m%r%=
set statusline+=%#WhiteOnYellow#%{init#AleWarnings()}%*
set statusline+=%#WhiteOnRed#%{init#AleErrors()}%*

" netrw {{{1
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_winsize = 15
let g:netrw_altv = 1
let g:netrw_list_hide = ',^\.git,__pycache__,rustc-incremental,^tags$'

" NERDCommenter {{{1
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCustomDelimiters = { 'inko': { 'left': '#' } }
let g:NERDCreateDefaultMappings = 0

" ALE {{{1
let g:ale_disable_lsp = 1
let g:ale_sign_error = '✖'
let g:ale_sign_warning = '●'
let g:ale_virtualtext_cursor = 0
let g:ale_echo_msg_format = '[%linter%]: %s'
let g:ale_lint_on_enter = 1
let g:ale_fix_on_save = 1
let g:ale_fix_on_enter = 0
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_linters = {
  \ 'rust': [],
  \ 'go': [],
  \ 'ruby': ['ruby', 'rubocop'],
  \ 'python': ['flake8'],
  \ 'markdown': ['vale']
  \ }

let g:ale_fixers = {
  \ 'javascript': 'prettier'
  \ }

let g:ale_python_flake8_auto_pipenv = 1

" Code completion {{{1
set omnifunc=v:lua.dotfiles.completion.start

autocmd CompleteDonePre * :lua dotfiles.completion.done()

" gutentags {{{1
let g:gutentags_ctags_exclude = [
  \ 'target',
  \ 'tmp',
  \ 'node_modules',
  \ 'public',
  \ '*/fixtures/*',
  \ '*/locale/*',
  \ '*.json',
  \ '*.svg'
  \ ]

let g:gutentags_file_list_command = 'rg --files'
let g:gutentags_ctags_extra_args = ['--exclude=@.gitignore', '--excmd=number']

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
  \ 'hl': ['bg', 'WhiteOnYellow'],
  \ 'hl+': ['bg', 'WhiteOnYellow'],
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
  \   'rg --color=never --no-filename --no-line-number '
  \     . fzf#shellescape(expand('%'))
  \     . ' tags | sort -s -t \t -k 1,1',
  \   {
  \     'placeholder': '{2}:{3}',
  \     'options': ['--prompt=>> ', '--reverse', '--no-sort', '--exact', '+i']
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
  \   {'options': ['--prompt=>> ', '--reverse', '--no-sort', '--exact', '+i']},
  \   <bang>0
  \ )

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg
  \     --column
  \     --line-number
  \     --no-heading
  \     --color=always
  \     --smart-case
  \     --colors match:none
  \     --colors match:fg:black
  \     --colors "match:bg:242,222,145"
  \     --colors path:none
  \     --colors path:style:bold
  \     --colors column:none
  \     --colors line:fg:blue '.shellescape(<q-args>),
  \   1,
  \   <bang>0
  \ )

" vsnip {{{1
let g:vsnip_snippet_dir = expand('~/.config/nvim/snippets')

" colortemplate {{{1
let g:colortemplate_toolbar = 0

" Rust {{{1
let g:rust_recommended_style = 0

" Trailing whitespace {{{1
function! s:Trim()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//eg
  call cursor(l, c)
endfunction

autocmd! BufWritePre * call <SID>Trim()
autocmd! BufWinEnter * match Visual /\s\+$/
autocmd! InsertEnter * match Visual /\s\+\%#\@<!$/
autocmd! InsertLeave * match Visual /\s\+$/
autocmd! BufWinLeave * call clearmatches()

" Buffer hooks {{{1
autocmd! BufRead,BufNewFile *.rll set filetype=rll
autocmd! BufRead,BufNewFile Dangerfile set filetype=ruby

function! init#formatBuffer() abort
  lua vim.lsp.buf.formatting_sync(nil, 1000)
endfunction

autocmd BufWritePre *.rs call init#formatBuffer()
autocmd BufWritePre *.go call init#formatBuffer()

" Mappings {{{1
" Generic {{{2
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

" FZF {{{2
map <silent> <leader>f :Files<CR>
map <silent> <leader>t :BTags<CR>
map <silent> <leader>b :Buffers<CR>
map <silent> <leader>l :BLines<CR>

" Fugitive {{{2
map <silent> <leader>gs :vert bo Gstatus<CR>
map <silent> <leader>gc :vert bo Gcommit<CR>
map <silent> <leader>gd :Gdiff<CR>

" LSP {{{2
map <silent> <leader>h :lua vim.lsp.buf.hover()<CR>
map <silent> <leader>r :lua vim.lsp.buf.rename()<CR>
map <silent> <leader>d :lua vim.lsp.buf.definition()<CR>
map <silent> <leader>i :lua vim.lsp.buf.references()<CR>
map <silent> <leader>a :lua vim.lsp.buf.code_action()<CR>

" Terminals {{{2

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

" Completion {{{2

" This allows cycling through popup menu results using tab, as well as
" performing keyword completion if the menu is not visible.
function! s:checkBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

function! init#tab() abort
  if pumvisible()
    return "\<C-n>"
  elseif s:checkBackSpace()
    return "\<tab>"
  else
    return "\<C-x>\<C-o>"
  end
endfunction

function! init#stab() abort
  if pumvisible()
    return "\<C-p>"
  else
    return "\<S-tab>"
  end
endfunction

function init#enter() abort
  if pumvisible()
    return v:lua.dotfiles.completion.confirm()
  else
    return "\<C-g>u\<CR>"
  end
endfunction

inoremap <silent><expr> <tab> init#tab()
inoremap <silent><expr> <S-tab> init#stab()
inoremap <silent><expr> <cr> init#enter()

" vsnip {{{2
imap <expr> <C-s> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-s>'
imap <expr> <C-j> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<C-j>'
imap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'

" NERD commenter {{{2
map <leader>c <plug>NERDCommenterToggle

" Custom commands {{{1
function! s:openTerm(cmd)
  exec a:cmd
  term
  startinsert
endfunction

command! Term call s:openTerm('new')
command! Vterm call s:openTerm('vnew')
command! Tterm call s:openTerm('tabnew')

" Close all buffers in the current tab. This is useful when viewing a diff in a
" tab and you want to close all buffers in that tab.
command! Tq windo q
command! Init e ~/.config/nvim/init.vim

" vim: fdm=marker
