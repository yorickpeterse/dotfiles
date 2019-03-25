let b:ale_linters = ['ruby', 'rubocop']
let b:ruby_no_expensive = 1

if !empty(findfile('Gemfile', expand('%:p:h') . ';'))
    " Automatically use `bundle exec` when we find a Gemfile
    let g:ale_ruby_rubocop_executable = 'bundle'
end
