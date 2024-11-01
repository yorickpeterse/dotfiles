dotfiles:
	stow dotfiles -t ~/

fedora:
	@fish containers/build.fish fedora

fedora-rpm:
	@fish containers/build.fish fedora-rpm

.PHONY: dotfiles fedora fedora-rpm
