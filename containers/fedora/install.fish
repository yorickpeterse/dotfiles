#!/usr/bin/env fish

source containers/helpers.fish

set pkgs (cat containers/fedora/packages.txt)
set copr (cat containers/fedora/coprs.txt)

# Make sure we're in the container's version of the dotfiles path.
cd ~/Projects/general/dotfiles

section 'Setting up the base system'
echo 'max_parallel_downloads=10' \
    | sudo tee --append /etc/dnf/dnf.conf >/dev/null

run sudo dnf install --assumeyes --quiet dnf-plugins-core
run sudo dnf update --assumeyes --quiet

section 'Setting up locale'
echo -e '
LANG=en_US.UTF-8
LC_NUMERIC=en_IE.UTF-8
LC_TIME=en_IE.UTF-8
LC_MONETARY=en_IE.UTF-8
LC_PAPER=en_IE.UTF-8
LC_MEASUREMENT=en_IE.UTF-8' | sudo tee /etc/locale.conf >/dev/null

section 'Enabling copr repositories'

for repo in $copr
    run sudo dnf copr enable --assumeyes \
        --quiet "copr.fedorainfracloud.org/$repo"
end

section 'Installing packages'
run sudo dnf install --assumeyes --quiet $pkgs

section 'Configuring Rust'
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >rustup.sh
run bash rustup.sh --default-toolchain stable -y --no-modify-path \
    --profile minimal \
    --component 'clippy,rustfmt,rust-analyzer'

section 'Configuring dotfiles'
rm -rf ~/.config/fish
run stow -R dotfiles -t ~/
source ~/.config/fish/config.fish
