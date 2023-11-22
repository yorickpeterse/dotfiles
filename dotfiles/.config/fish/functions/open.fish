function open -d 'Opens a given file or directory'
    if set -q argv[1]
        set path (realpath $argv[1])
    else
        echo 'You must specify a path to open'
        return 1
    end

    # This ensures that when the command is run from a container, these mounted
    # directories are openend using the correct host path. This would be a lot
    # easier if we could just "overlay" the container's $HOME on top of the
    # host's $HOME.
    if test -n "$CONTAINER_ID"
        set path (string replace --regex \
            "/var/home/$USER/homes/$CONTAINER_ID/(Projects|Downloads)" \
            "/var/home/$USER/\$1" $path)

        /usr/bin/distrobox-host-exec xdg-open $path
    else
        /usr/bin/xdg-open $path
    end
end
