set -x CHRUBY_ROOT /usr

source /usr/share/chruby/chruby.fish
source /usr/share/chruby/auto.fish
source $HOME/.config/fish/private.fish

set -x EDITOR $HOME/bin/editor
set -x PATH $HOME/.cargo/bin $HOME/bin $HOME/.local/bin $HOME/.local/share/ivm/bin $PATH
set -x DISABLE_SPRING '1'
set -x NOKOGIRI_USE_SYSTEM_LIBRARIES 'true'
set -x NVIM_TUI_ENABLE_TRUE_COLOR 1
set -x BUNDLE_DISABLE_VERSION_CHECK 1
set -x QT_AUTO_SCREEN_SCALE_FACTOR 1
set -x LS_COLORS 'di=0;35:ln=1;34:ex=1;30'

set fish_greeting
set fish_color_command normal --bold
set fish_color_param normal
set fish_color_quote green
set fish_color_cwd purple
set fish_color_error red --bold
set fish_color_status red
set fish_color_comment 777777
set fish_color_operator normal
set fish_color_redirection normal --bold
set fish_color_end normal
set fish_color_search_match --background=bfbcaf
set fish_color_match normal
set fish_color_autosuggestion $fish_color_comment

set fish_pager_color_prefix normal --bold
set fish_pager_color_progress normal --bold
set fish_pager_color_completion normal
set fish_pager_color_description $fish_color_comment

chruby_reset
chruby (cat $HOME/.ruby-version)
