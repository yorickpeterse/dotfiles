dotfiles:
	@fish dotfiles.fish

fedora:
	@fish containers/build.fish fedora

arch:
	@fish containers/build.fish arch

qmk:
	@fish containers/build.fish qmk

.PHONY: arch dotfiles fedora qmk
