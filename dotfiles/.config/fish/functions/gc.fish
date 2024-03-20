function gc -d 'git commit' --wraps='git commit'
    git commit $argv
end
