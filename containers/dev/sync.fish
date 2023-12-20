#!/usr/bin/env fish

source containers/helpers.fish
set dir containers/dev
set pkgs (cat $dir/packages.txt)
set aur (cat $dir/aur.txt)

section 'Installing packages'
run sudo pacman --sync --refresh --sysupgrade --noconfirm --needed --quiet $pkgs

section 'Installing AUR packages'
run yay --sync --refresh --sysupgrade --noconfirm --needed --quiet $aur
