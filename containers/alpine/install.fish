#!/usr/bin/env fish

source containers/helpers.fish

# The packages to install.
set pkgs (cat containers/alpine/packages.txt)

section 'Installing packages'
run sudo apk add --update --quiet --no-interactive --no-progress $pkgs

install_dotfiles
install_fonts
