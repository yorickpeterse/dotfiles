#!/usr/bin/env fish

set dir containers/arch

echo -e "\e[1mNew regular packages:\e[0m"
pacman --query --explicit --quiet --native | sort >/tmp/packages.txt
comm -2 -3 /tmp/packages.txt $dir/packages.txt >/tmp/new.txt
comm -2 -3 /tmp/new.txt $dir/ignore.txt

echo -e "\n\e[1mNew AUR packages:\e[0m"
pacman --query --explicit --quiet --foreign | grep -Pv yay | sort >/tmp/aur.txt
comm -2 -3 /tmp/aur.txt $dir/aur.txt
