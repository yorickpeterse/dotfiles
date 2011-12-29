help:
	@echo "Commands"
	@echo
	@echo "vim    # Sets up Vim"
	@echo "tmux   # Copies the .tmux.conf file to Â~/"
	@echo "git    # Sets the global .gitignore"
	@echo "mutt   # Creates all the files and folders for Mutt"

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

mutt:
	@mkdir -p ${HOME}/.mutt/cache/headers/
	@mkdir ${HOME}/.mutt/cache/bodies/
	@mkdir ${HOME}/.mutt/accounts/
