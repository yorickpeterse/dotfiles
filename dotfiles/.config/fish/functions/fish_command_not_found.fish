function fish_command_not_found
    if test -e /run/.containerenv
        distrobox-host-exec $argv
    else
        __fish_default_command_not_found_handler $argv
    end
end
