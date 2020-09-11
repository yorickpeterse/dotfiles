let b:ale_command_wrapper = 'ruby-exec'

if !empty(findfile('Gemfile', expand('%:p:h') . ';'))
    " Automatically use `bundle exec` when we find a Gemfile
    let b:ale_ruby_rubocop_executable = 'bundle'
end
