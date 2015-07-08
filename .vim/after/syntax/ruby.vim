" Folds all multi-line comments, taken from
" http://stackoverflow.com/a/14796044/290102
set fdm=expr
set fde=getline(v:lnum)=~'^\\s#'?1:getline(prevnonblank(v:lnum))=~'^\\s#'?1:getline(nextnonblank(v:lnum))=~'^\\s*#'?1:0
