function section
    echo -e "\n\e[1m$argv\e[0m"
end

cd fedora

section 'Configuring DNF'
sudo cp dnf.conf /etc/dnf/dnf.conf

section 'Removing default applications'
sudo dnf remove --assumeyes --quiet (cat remove.txt)

section 'Configuring copr'
for repo in (cat coprs.txt)
    sudo dnf copr enable --assumeyes --quiet $repo
end

section 'Installing packages'
sudo dnf install --assumeyes --quiet (cat packages.txt)

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
flatpak install (cat flatpak.txt)
