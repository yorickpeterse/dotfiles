function gl -d 'git log' --wrap='git log'
    git log \
        --pretty="format:%C(auto,yellow bold)%h %C(auto,normal reset)%<(16)%ad %C(auto,#5e5e5e reset)%<(14,trunc)%aN %C(auto,reset)%s%C(auto,yellow bold)%d" \
        $argv
end
