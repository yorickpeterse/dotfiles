dotfiles:
	stow dotfiles -t ~/

fedora:
	fish containers/build.fish fedora fedora:38

arch:
	fish containers/build.fish arch archlinux:latest

.PHONY: dotfiles fedora arch
