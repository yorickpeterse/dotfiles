dotfiles:
	stow dotfiles -t ~/

fedora:
	@fish containers/build.fish fedora

fedora-rpm:
	@fish containers/build.fish fedora-rpm

tumbleweed:
	@fish containers/build.fish tumbleweed

.PHONY: dotfiles fedora fedora-rpm tumbleweed
