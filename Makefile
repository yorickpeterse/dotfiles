dotfiles:
	@fish dotfiles.fish

fedora-rpm:
	@fish containers/build.fish fedora-rpm

arch:
	@fish containers/build.fish arch

.PHONY: arch dotfiles fedora fedora-rpm
