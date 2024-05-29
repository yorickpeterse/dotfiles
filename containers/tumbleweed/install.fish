#!/usr/bin/env fish

source ../helpers.fish

set completions /etc/fish/completions

section 'Configuring Ghostty'
run sudo cp -r ~/.local/share/terminfo/* /usr/share/terminfo

source ~/.config/fish/config.fish

section 'Generating completions'
run flatpak-spawn --host podman completion fish \| sudo tee $completions/podman.fish
