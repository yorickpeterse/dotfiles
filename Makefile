dotfiles:
	stow dotfiles -t ~/

fedora:
	fish containers/build.fish fedora fedora:latest

arch:
	fish containers/build.fish arch archlinux:latest

alpine:
	fish containers/build.fish alpine alpine:latest

.PHONY: dotfiles fedora arch alpine
