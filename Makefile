dotfiles:
	@fish dotfiles.fish

fedora-rpm:
	@fish containers/build.fish fedora-rpm

arch:
	@fish containers/build.fish arch

qmk:
	@fish containers/build.fish qmk

.PHONY: arch dotfiles fedora-rpm qmk
