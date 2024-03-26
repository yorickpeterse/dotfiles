#!/usr/bin/env fish

source containers/helpers.fish

set pkgs (cat containers/packages.txt)
set copr (cat containers/coprs.txt)
set pip (cat containers/pip.txt)
set completions /etc/fish/completions

section 'Setting up the base system'
echo 'max_parallel_downloads=10' | sudo tee --append /etc/dnf/dnf.conf >/dev/null
run sudo dnf5 install --assumeyes --quiet dnf-plugins-core
run sudo dnf5 update --assumeyes --quiet

section 'Enabling copr repositories'
for repo in $copr
    run sudo dnf5 copr enable --assumeyes \
        --quiet "copr.fedorainfracloud.org/$repo"
end

section 'Installing packages'
run sudo dnf5 install --assumeyes --quiet $pkgs

section 'Installing Python packages'
run pip install --quiet $pip

section 'Installing rustup'
run rustup-init --quiet -y --no-modify-path

section 'Configuring Ruby'
echo 'gem: --no-document --user' >~/.gemrc
run gem install --silent pry pry-doc pry-theme

source ~/.config/fish/config.fish

section 'Configuring Rust'
run rustup install stable
run rustup component add rust-src rust-analyzer clippy rustfmt
cp containers/cargo-config.toml ~/.cargo/config.toml

if ! test -f ~/.config/ivm/version
    section 'Configuring Inko'
    run ivm install latest
    run ivm default (ivm list)
    run ivm clean
end

section 'Generating completions'
run flatpak-spawn --host podman completion fish \| sudo tee $completions/podman.fish
run rustup completions fish \| sudo tee $completions/rustup.fish
