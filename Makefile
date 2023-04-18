FEDORA_VERSION := 38

dotfiles:
	stow dotfiles -t ~/

fedora:
	@mkdir -p ${PWD}/homes/fedora
	@distrobox enter fedora -- fish ${PWD}/fedora/backup.fish > ${PWD}/seed.fish
	@podman container rename fedora fedora-old
	@distrobox create \
		--pull \
		--image fedora:${FEDORA_VERSION} \
		--name fedora \
		--home ${HOME}/homes/fedora \
		--no-entry
	@distrobox enter fedora -- fish ${PWD}/seed.fish
	@rm ${PWD}/seed.fish

.PHONY: dotfiles fedora
