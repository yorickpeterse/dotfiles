help:
	@echo "Commands"
	@echo
	@echo "vim    # Sets up Vim"
	@echo "tmux   # Copies the .tmux.conf file to ~/"
	@echo "git    # Sets the global .gitignore"
	@echo "mutt   # Creates all the files and folders for Mutt"

vim:
	@git submodule init
	@git submodule update
	@ln -s ./.vim ~/.vim
	@ln -s ./.vimrc ~/.vimrc
	@ln -s ./.gvimrc ~/.gvimrc

tmux:
	@cp ./.tmux.conf ~/.tmux.conf

git:
	@cp .gitignore_global ~/.gitignore_global
	@git config --global core.excludesfile ~/.gitignore_global

mutt:
	@mkdir -p ~/.mutt/cache/headers/
	@mkdir ~/.mutt/cache/bodies/
	@mkdir ~/.mutt/accounts/
