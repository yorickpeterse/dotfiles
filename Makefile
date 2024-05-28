dotfiles:
	stow dotfiles -t ~/

fedora:
	@fish containers/build.fish fedora

.PHONY: dotfiles fedora
