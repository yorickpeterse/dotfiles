dotfiles:
	stow dotfiles -t ~/

arch:
	@fish containers/build.fish arch archlinux:latest

fedora:
	@fish containers/build.fish fedora fedora:latest

alpine:
	@fish containers/build.fish alpine alpine:latest

.PHONY: dotfiles fedora arch alpine
