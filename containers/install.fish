#!/usr/bin/env fish

source containers/helpers.fish

set pkgs (cat containers/packages.txt)
set copr (cat containers/coprs.txt)
set pip (cat containers/pip.txt)

section 'Setting up the base system'
echo 'max_parallel_downloads=10' | sudo tee --append /etc/dnf/dnf.conf >/dev/null
run sudo dnf install --assumeyes --quiet dnf-plugins-core
run sudo dnf update --assumeyes --quiet

section 'Enabling copr repositories'
for repo in $copr
    run sudo dnf copr enable --assumeyes \
        --quiet "copr.fedorainfracloud.org/$repo"
end

section 'Installing packages'
run sudo dnf install --assumeyes --quiet $pkgs

section 'Installing Python packages'
run pip install --quiet $pip

section 'Installing rustup'
run rustup-init --quiet -y --no-modify-path

section 'Configuring Ruby'
echo 'gem: --no-document --user' >~/.gemrc
run gem install --silent pry pry-doc pry-theme

source ~/.config/fish/config.fish

install_rust
install_inko
