#!/usr/bin/env fish

source containers/helpers.fish

# The regular packages to install.
set pkgs (cat containers/fedora/packages.txt)

# The Copr packages to install.
set copr (cat containers/fedora/coprs.txt)

section 'Setting up the base system'
echo 'max_parallel_downloads=10' | sudo tee --append /etc/dnf/dnf.conf >/dev/null
run sudo dnf install --assumeyes --quiet dnf-plugins-core
run sudo dnf update --assumeyes --quiet

section 'Enabling manual pages'
run sudo dnf -y reinstall (rpm -qads --qf "PACKAGE: %{NAME}\n" \
    | sed -n -E '/PACKAGE: /{s/PACKAGE: // ; h ; b }; /^not installed/ { g; p }' \
    | uniq)

install_locales

section 'Enabling copr repositories'

for repo in $copr
    run sudo dnf copr enable --assumeyes \
        --quiet "copr.fedorainfracloud.org/$repo"
end

section 'Installing packages'
run sudo dnf install --assumeyes --quiet $pkgs

install_dotfiles
install_fonts

section 'Installing rustup'
run rustup-init --quiet -y --no-modify-path

install_rust
