syn match snippetKeyword '^snippet'me=s+8 contained
syn region snippetDesc start='"' end='"' contained
syn match snippet '^snippet.\+$' contains=snippetKeyword,snippetDesc
syn match snipError "^[^#vse\t ].*$"

hi link snippetKeyword Keyword
hi link snippetDesc String
hi link snipError Error
