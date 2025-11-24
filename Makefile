dotfiles:
	@fish dotfiles.fish

fedora:
	@fish fedora/setup.fish

fedora-rpm:
	@fish containers/build.fish fedora-rpm

qmk:
	@fish containers/build.fish qmk

.PHONY: dotfiles fedora fedora-rpm qmk
