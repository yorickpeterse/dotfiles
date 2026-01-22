#!/usr/bin/env fish

set src $PWD/dotfiles

# Setting up dotfiles is done from a shell which will set up this directory,
# preventing us from setting up the symbolic link.
if test -d ~/.config/fish
    rm -rf ~/.config/fish
end

rm -rf ~/bin
ln -s -f $src/bin ~/bin
ln -s -f $src/.config/* ~/.config/
rm -f ~/.local/share/icons
ln -s -f $src/.local/share/icons ~/.local/share/icons

rm -f ~/.local/share/org.gnome.Ptyxis
ln -s -f $src/.local/share/org.gnome.Ptyxis ~/.local/share/org.gnome.Ptyxis

# This directory may have custom entries per host, so we only link the
# individual files.
mkdir -p ~/.local/share/applications
ln -s -f $src/.local/share/applications/*.desktop ~/.local/share/applications

for path in $src/{*,.*}
    if test -f $path
        ln -s -f $path ~/
    end
end
