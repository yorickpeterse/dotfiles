default_target: help

help:
	@echo "all         # Sets up everything"
	@echo "nvim        # Sets up Neovim"
	@echo "tmux        # Copies the .tmux.conf file to ~/"
	@echo "git         # Sets the global .gitignore"
	@echo "fonts       # Configures X11 to properly render fonts"
	@echo "pry         # Creates the configuration files for Pry"
	@echo "keybindings # Configures keybindings"
	@echo "fish        # Configures fish"

all:
	@make nvim
	@make tmux
	@make git
	@make fonts
	@make pry
	@make keybindings

vim:
	@ln -s ${PWD}/.config/nvim ${HOME}/.config/nvim

tmux:
	@ln -s ${PWD}/.tmux.conf ${HOME}/.tmux.conf

git:
	@ln -s ${PWD}/.gitignore_global ${HOME}/.gitignore_global
	@ln -s ${PWD}/.gitconfig ${HOME}/.gitconfig

fonts:
	@ln -s ${PWD}/.Xdefaults ${HOME}/.Xdefaults
	@mkdir -p ${HOME}/.config/fontconfig
	@ln -s ${PWD}/.fonts.conf ${HOME}/.config/fontconfig/fonts.conf

pry:
	@ln -s ${PWD}/.pryrc ${HOME}/.pryrc

keybindings:
	@ln -s ${PWD}/.Xmodmap ${HOME}/.Xmodmap
	@xmodmap ${HOME}/.Xmodmap

fish:
	@ln -s ${PWD}/.config/fish ${HOME}/.config/
