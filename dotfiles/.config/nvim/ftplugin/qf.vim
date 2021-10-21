" Open the quickfix window at the bottom of all other windows, while leaving the
" location lists as-is.
"
" Taken from https://github.com/fatih/vim-go/issues/108#issuecomment-565131948.
if getwininfo(win_getid())[0].loclist != 1
  wincmd J

  au WinClosed <buffer> :lua dotfiles.hooks.close_quickfix()
endif

setlocal nolist
