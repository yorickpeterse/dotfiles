dotfiles:
	stow dotfiles -t ~/

container:
	@fish containers/build.fish

.PHONY: dotfiles container
