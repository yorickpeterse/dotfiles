dotfiles:
	@fish dotfiles.fish

fedora:
	@fish containers/build.fish fedora

qmk:
	@fish containers/build.fish qmk

.PHONY: dotfiles fedora qmk
