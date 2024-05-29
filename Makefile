dotfiles:
	stow dotfiles -t ~/

fedora:
	@fish containers/build.fish fedora

tumbleweed:
	@fish containers/build.fish tumbleweed

.PHONY: dotfiles fedora
