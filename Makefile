help:
	@echo "Commands"
	@echo
	@echo "vim    # Sets up Vim"
	@echo "tmux   # Copies the .tmux.conf file to ~/"
	@echo "git    # Sets the global .gitignore"

vim:
	@git submodule init
	@git submodule update
	@ln -s ${PWD}/.vim ${HOME}/.vim
	@ln -s ${PWD}/.vimrc ${HOME}/.vimrc
	@ln -s ${PWD}/.gvimrc ${HOME}/.gvimrc

tmux:
	@cp ${PWD}/.tmux.conf ${HOME}/.tmux.conf

git:
	@cp .gitignore_global ${HOME}/.gitignore_global
	@git config --global core.excludesfile ${HOME}/.gitignore_global
