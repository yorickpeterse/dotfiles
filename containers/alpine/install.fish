#!/usr/bin/env fish

source containers/helpers.fish

set pkgs (cat containers/alpine/packages.txt)

# Make sure we're in the container's version of the dotfiles path.
cd ~/Projects/general/dotfiles

section 'Configuring Rust'
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >rustup.sh
run sh rustup.sh --default-toolchain stable -y --no-modify-path \
    --profile minimal \
    --component 'clippy,rustfmt,rust-analyzer'
rm rustup.sh

section 'Installing packages'
run sudo apk add --update --quiet --no-interactive --no-progress $pkgs

section 'Configuring dotfiles'
rm -rf ~/.config/fish
run stow -R dotfiles -t ~/
source ~/.config/fish/config.fish
