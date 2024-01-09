dotfiles:
	stow dotfiles -t ~/

arch:
	@fish containers/build.fish arch archlinux:latest

arch/diff:
	@fish containers/arch/diff.fish

fedora:
	@fish containers/build.fish fedora fedora:latest

alpine:
	@fish containers/build.fish alpine alpine:latest

.PHONY: dotfiles fedora arch alpine arch/packages
