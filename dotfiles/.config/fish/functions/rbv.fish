# The smallest Ruby version manager in the west.
function rbv
    if set -q argv[1]
        set --global --export RBV_VERSION $argv[1]
        set ruby_root $HOME/.rubies/$RBV_VERSION
        set ruby_bin $ruby_root/bin

        if not test -d $ruby_root
            echo "The version $RBV_VERSION is invalid"
            return 1
        end

        # Remove the existing entry from the PATH, if any.
        if set index (contains -i $ruby_bin $PATH)
            set --erase --global fish_user_paths[$index]
        end

        set --global --export RUBY_ROOT $ruby_root
        fish_add_path --global $ruby_bin
    else
        for dir in ~/.rubies/*
            set name (basename $dir)

            if test "$name" = "$RBV_VERSION"
                echo "$name (current)"
            else
                echo "$name"
            end
        end
    end
end
