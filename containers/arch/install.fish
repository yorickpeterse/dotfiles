#!/usr/bin/env fish

source containers/helpers.fish
set dir containers/arch

# The regular packages to install.
set pkgs (cat $dir/packages.txt)

# The AUR packages to install.
set aur (cat $dir/aur.txt)

# The version of Ruby to install.
set ruby_version 3.2.2

# The locale to use in addition to the standard en_US locale.
set locale en_IE.UTF-8

# The country to use for the package mirrors.
set country NL

section 'Setting up the base system'
run sudo sed -i -e 's/ParallelDownloads = 5/ParallelDownloads = 10/' \
    /etc/pacman.conf
run sudo sed -i -e 's/#Color/Color/' /etc/pacman.conf

# Manual pages aren't included in the container, so we need to fix that.
run sudo pacman -Syu --noprogressbar --noconfirm --quiet --needed \
    sudo man-db man-pages
run sudo mandb --quiet

# Ensure the pacman manual pages are installed.
run sudo pacman -Syu pacman --noprogressbar --noconfirm --quiet

section 'Setting up locale'
run sudo cp /run/host/etc/locale.conf /etc/locale.conf
run sudo chown root:root /etc/locale.conf
echo -e "en_US.UTF-8 UTF-8\n$locale UTF-8" | sudo tee /etc/locale.gen >/dev/null
run sudo locale-gen

section 'Installing packages'
run sudo pacman -Syu --noprogressbar --noconfirm --quiet reflector
run sudo reflector --save /etc/pacman.d/mirrorlist \
    --country $country \
    --protocol https \
    --latest 10 \
    --fastest 10

run sudo pacman -Syu --noprogressbar --noconfirm --needed --quiet $pkgs

section 'Installing AUR wrapper'
rm -rf /tmp/yay
run git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
run makepkg -si --noconfirm
cd -
rm -rf /tmp/yay

section 'Configuring dotfiles'
run rm -rf ~/.config/fish
run stow -R dotfiles -t ~/
source ~/.config/fish/config.fish

section 'Configuring Rust'
run rustup install stable
run rustup component add rust-src rust-analyzer clippy rustfmt

section 'Installing AUR packages'
run yay -Syu --noprogressbar --noconfirm --needed --quiet --mflags --nocheck \
    $aur

run yay -Scc --noconfirm --quiet

section 'Configuring Ruby'
run ruby-install --jobs 8 --no-install-deps --no-reinstall $ruby_version
run rm -rf ~/src
echo ruby-$ruby_version >~/.ruby-version
echo 'gem: --no-document' >~/.gemrc

rbv ruby-$ruby_version
run gem update --system --silent
run gem install --silent pry pry-doc pry-theme

if ! test -f ~/.local/share/ivm/version
    section 'Configuring Inko'
    run ivm install latest
    run ivm default (ivm list)
    run ivm clean
end
