function section
    echo -e "\n\e[1m$argv\e[0m"
end

cd fedora/post

if ! test -d ~/.rustup
    section 'Configuring Rust'
    set rustup ~/.cargo/bin/rustup

    rustup-init --quiet -y --no-modify-path
    $rustup install stable
    $rustup default stable
    $rustup component add rust-src rust-analyzer clippy rustfmt
    cp cargo-config.toml ~/.cargo/config.toml
end

if ! test -f ~/.config/ivm/version
    section 'Configuring Inko'
    ivm install latest
    ivm default (ivm list | cut -d ' ' -f 1)
    ivm clean
end

section 'Installing Flatpak applications'
flatpak install --noninteractive (cat flatpak.txt)

section 'Changing shell'
chsh -s (which fish) $USER
