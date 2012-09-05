" ============================================================================
" HTML SYNTAX FILE
"
" Extends the HTML syntax so that it supports highlighting for Etanni template
" tags.
"

unlet b:current_syntax

syn include @rubyTop syntax/ruby.vim

syn region etanniOutput    matchgroup=etanniDelimiter start="#{"  end="}"  keepend contains=@rubyTop
syn region etanniStatement matchgroup=etanniDelimiter start="<?r" end="?>" keepend contains=@rubyTop
