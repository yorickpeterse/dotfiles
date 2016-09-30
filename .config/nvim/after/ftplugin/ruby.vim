" ============================================================================
" RUBY FTPLUGIN FILE
"
" File that is executed after opening a Ruby file. This file is used to disable
" those annoying tooltips that show up when hovering over Ruby code. I've
" disabled this because:
"
" 1. they're annoying as hell
" 2. they don't seem to work and will instead just show a big warning from
"    `ri`.
"
setlocal balloonexpr=
