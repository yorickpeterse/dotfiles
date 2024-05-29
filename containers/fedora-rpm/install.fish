#!/usr/bin/env fish

source ../helpers.fish
source ~/.config/fish/config.fish

section 'Configuring Ghostty'
run sudo cp -r ~/.local/share/terminfo/* /usr/share/terminfo
