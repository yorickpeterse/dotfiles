dotfiles:
	stow dotfiles -t ~/

fedora:
	@mkdir -p ${PWD}/homes/fedora
	@distrobox enter fedora -- fish ${PWD}/fedora/backup.fish > ${PWD}/seed.fish
	@distrobox create --image fedora:38 --name fedora --home ${PWD}/homes/fedora --no-entry
	@distrobox enter fedora -- fish ${PWD}/seed.fish
	@rm ${PWD}/seed.fish

.PHONY: dotfiles fedora
