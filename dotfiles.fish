#!/usr/bin/env fish

set src $PWD/dotfiles

# Setting up dotfiles is done from a shell which will set up this directory,
# preventing us from setting up the symbolic link.
if test -d ~/.config/fish
    rm -rf ~/.config/fish
end

ln --symbolic --force --no-target-directory $src/bin ~/bin
ln --symbolic --force $src/.config/* ~/.config/

# This directory may have custom entries per host, so we only link the
# individual files.
ln --symbolic --force $src/.local/share/applications/*.desktop \
    ~/.local/share/applications

for path in $src/dotfiles
    if test -f $path
        ln --symbolic --force $path ~/
    end
end
