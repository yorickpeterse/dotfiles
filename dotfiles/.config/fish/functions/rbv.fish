# The smallest Ruby version manager in the west.
function rbv
    if set -q argv[1]
        set -g -x RBV_VERSION $argv[1]
        set ruby_root "$HOME/.rubies/$RBV_VERSION"

        if not test -d $ruby_root
            echo "The version $RBV_VERSION is invalid"
            return 1
        end

        set -g -x RUBY_ROOT "$HOME/.rubies/$RBV_VERSION"

        fish_add_path -g "$RUBY_ROOT/bin"
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
