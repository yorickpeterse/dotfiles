set -x CHRUBY_ROOT /usr

source /usr/share/chruby/chruby.fish
source $HOME/.config/fish/private.fish

set -x TERM 'screen-256color'
set -x EDITOR 'gvim -f'
set -x PATH $PATH $HOME/bin

set fish_greeting
set fish_color_command normal
set fish_color_param normal
set fish_color_quote green
set fish_color_cwd yellow
set fish_color_cwd_root yellow
set fish_color_error red
set fish_color_status red
set fish_color_comment 9e9e9e
set fish_color_operator normal
set fish_color_redirection yellow
set fish_color_end yellow
set fish_color_search_match --background=333333
set fish_color_valid_path
set fish_color_match yellow
set fish_color_autosuggestion $fish_color_comment

set fish_pager_color_prefix yellow
set fish_pager_color_progress yellow
set fish_pager_color_completion normal
set fish_pager_color_description $fish_color_comment

chruby_reset
chruby (cat $HOME/.ruby-version)
