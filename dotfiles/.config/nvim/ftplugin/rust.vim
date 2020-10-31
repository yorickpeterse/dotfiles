let rustfmt_config_path = findfile('rustfmt.toml', expand('%:p:h') . ';')

" This ensures we only pass an explicit configuration file if we managed to find
" one.
if empty(rustfmt_config_path)
  let b:ale_rust_rustfmt_options = ''
else
  let b:ale_rust_rustfmt_options = '--config-path='
        \ . fnamemodify(rustfmt_config_path, ':p')
end

inoremap <silent><expr> <tab> init#tabCompleteLSP()
