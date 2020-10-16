setlocal spell spelllang=en

" Only enable gitlint if there is a .gitlint config file, as by default gitlint
" is a bit too pedantic.
let config = findfile('.gitlint', expand('%:p:h') . ';')

if empty(config)
  let b:ale_linters = []
else
  let b:ale_linters = ['gitlint']
  let b:ale_gitcommit_gitlint_options = '-C ' . fnamemodify(config, ':p')
end
