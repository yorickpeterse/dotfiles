function fish_prompt
    if [ $PWD = $HOME ]
        set directory '~'
    else
        set directory (basename $PWD)
    end

    if test -n "$CONTAINER_ID"
        echo -n "[$CONTAINER_ID] "
    else
        echo -n "[$hostname] "
    end

    set_color $fish_color_cwd
    echo -n $directory
    set_color normal
    echo -n " \$ "
end
