if exists('b:current_syntax')
  finish
end

syntax clear

syn region snippetHeader
  \ matchgroup=snippetOpen
  \ start='^snippet\>'
  \ end='$'
  \ oneline
  \ contains=snippetName,snippetDesc

syn match snippetComment '^#.*'
syn keyword snippetClose endsnippet

syn region snippetDesc start="\"" end="\"" skip="\\\\\|\\\"" contained
syn match snippetError "^[^#vse\t].*$"

hi link snippetOpen Keyword
hi link snippetClose Keyword
hi link snippetDesc String
hi link snippetError SpellBad
hi link snippetComment Comment

let b:current_syntax = "snippets"
