" Custom syntax file for quickfix/location lists, supporting my custom
" formatting.

if exists('b:current_syntax')
    finish
end

syntax clear

let b:current_syntax = 'qf'

syn match qfError '^E ' nextgroup=qfPath
syn match qfWarning '^W ' nextgroup=qfPath
syn match qfPath '^\(E \|W \)\@![^:]\+' nextgroup=qfPosition

syn match qfPath '[^:]\+' nextgroup=qfPosition contained
syn match qfPosition ':[0-9]\+:[0-9]\+' contained

hi def link qfPath Directory
hi def link qfPosition Number
hi def link qfError ErrorMsg
hi def link qfWarning Yellow
