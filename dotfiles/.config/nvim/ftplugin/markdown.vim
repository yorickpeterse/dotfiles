setlocal spell spelllang=en

" https://github.com/neovim/neovim/commit/68c674af0fbc4158690319aa6125a098a592412d
" means a format expression is set. Sadly there are no Markdown formatters/LSP
" servers that support all the different styles of Markdown, so I have this
" disabled here.
setlocal formatexpr={->1}
