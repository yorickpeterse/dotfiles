if test -e $HOME/.config/fish/private.fish
    source $HOME/.config/fish/private.fish
end

fish_add_path $HOME/bin $HOME/.cargo/bin $HOME/.local/bin $HOME/.local/share/ivm/bin

set -x EDITOR $HOME/bin/nvim
set -x DISABLE_SPRING 1
set -x NOKOGIRI_USE_SYSTEM_LIBRARIES true
set -x NVIM_TUI_ENABLE_TRUE_COLOR 1
set -x BUNDLE_DISABLE_VERSION_CHECK 1
set -x QT_AUTO_SCREEN_SCALE_FACTOR 1
set -x LS_COLORS 'di=0;35:ln=1;34:ex=1;30'
set -x DEBUGINFOD_URLS 'https://debuginfod.archlinux.org'

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
set fish_color_search_match --background=dddddd
set fish_color_match normal
set fish_color_autosuggestion $fish_color_comment
set fish_color_valid_path

set fish_pager_color_prefix normal --bold
set fish_pager_color_progress normal --bold
set fish_pager_color_completion normal
set fish_pager_color_description $fish_color_comment
set fish_pager_color_selected_background --background=dddddd

if test -e $HOME/.ruby-version
    rbv (cat $HOME/.ruby-version)
end
