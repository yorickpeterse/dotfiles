" Open the quickfix window at the bottom of all other windows, while leaving the
" location lists as-is.
"
" Taken from https://github.com/fatih/vim-go/issues/108#issuecomment-565131948.
if getwininfo(win_getid())[0].loclist != 1
  " Ensures the window is always at the bottom, no matter the command that
  " triggered opening of a quickfix window.
  wincmd J

  " Ensures the window is always the same height.
  res 10

  lua dotfiles.quickfix.resize()
  au WinClosed <buffer> :lua dotfiles.quickfix.closed()
endif

setlocal nolist

nnoremap <silent> <buffer> <CR> :lua dotfiles.quickfix.open_item()<CR>
nnoremap <silent> <buffer> <leader>v :lua dotfiles.quickfix.open_item('vsplit')<CR>
nnoremap <silent> <buffer> <leader>k :lua dotfiles.quickfix.open_item('split')<CR>
