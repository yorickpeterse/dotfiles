unlet b:current_syntax

syn include @rubyTop syntax/ruby.vim

syn region etanniOutput    matchgroup=etanniDelimiter start="#{"  end="}"  contains=@rubyTop
syn region etanniStatement matchgroup=etanniDelimiter start="<?r" end="?>" contains=@rubyTop
