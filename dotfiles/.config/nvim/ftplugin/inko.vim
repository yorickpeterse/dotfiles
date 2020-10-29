if expand('%:p') =~? 'runtime'
  let find = 'target/release/inko'
  let bin = findfile(find, expand('%:p:h') . ';')

  if !empty(bin)
    let b:ale_inko_inko_executable = bin
  endif
endif
