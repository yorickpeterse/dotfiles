#!/usr/bin/env sh

dir="/var/home/yorickpeterse/Projects/general/dotfiles/containers/dev"

pacman --query --explicit --quiet --native \
    | grep -v vulkan > "${dir}/packages.txt"

pacman --query --explicit --quiet --foreign | grep -v yay > "${dir}/aur.txt"
