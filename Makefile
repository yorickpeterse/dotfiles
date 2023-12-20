dotfiles:
	stow dotfiles -t ~/

dev/build:
	@fish containers/dev.fish

dev/sync:
	@fish containers/dev/sync.fish

fedora:
	@fish containers/build.fish fedora fedora:latest

alpine:
	@fish containers/build.fish alpine alpine:latest

.PHONY: dotfiles fedora dev dev/sync alpine
