#!/usr/bin/env fish

source ../helpers.fish

set pip (cat pip.txt)
set completions /etc/fish/completions

section 'Configuring Ghostty'
run sudo cp -r ~/.local/share/terminfo/* /usr/share/terminfo

section 'Installing Python packages'
run pip install --quiet $pip

section 'Installing rustup'
run rustup-init --quiet -y --no-modify-path

section 'Installing Rust toolchain for Inko'
run rustup toolchain install 1.70.0 -c clippy -c rustfmt -c rust-analyzer

section 'Configuring Ruby'
echo 'gem: --no-document --user --bindir ~/.local/share/gem/ruby/bin' >~/.gemrc
run gem install --silent pry pry-doc pry-theme

source ~/.config/fish/config.fish

section 'Configuring Rust'
run rustup install stable
run rustup component add rust-src rust-analyzer clippy rustfmt
cp cargo-config.toml ~/.cargo/config.toml

if ! test -f ~/.config/ivm/version
    section 'Configuring Inko'
    run ivm install latest
    run ivm default (ivm list)
    run ivm clean
end

section 'Generating completions'
run flatpak-spawn --host podman completion fish \| sudo tee $completions/podman.fish
run rustup completions fish \| sudo tee $completions/rustup.fish
