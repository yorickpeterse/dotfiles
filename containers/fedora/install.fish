#!/usr/bin/env fish

source ../helpers.fish
source ~/.config/fish/config.fish

set completions /etc/fish/completions

section 'Configuring Rust'
run rustup install stable
run rustup default stable
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
