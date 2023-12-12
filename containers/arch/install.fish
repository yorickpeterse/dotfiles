#!/usr/bin/env fish

source containers/helpers.fish

set dir containers/arch
set pkgs (cat $dir/packages.txt)
set aur (cat $dir/aur.txt)
set ruby_version 3.2.2

# Make sure we're in the container's version of the dotfiles path.
cd ~/Projects/general/dotfiles

section 'Setting up the base system'
run sudo pacman-key --init
run sudo pacman-key --populate
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
echo -e '
LANG=en_US.UTF-8
LC_NUMERIC=en_IE.UTF-8
LC_TIME=en_IE.UTF-8
LC_MONETARY=en_IE.UTF-8
LC_PAPER=en_IE.UTF-8
LC_MEASUREMENT=en_IE.UTF-8' | sudo tee /etc/locale.conf >/dev/null

echo -e "en_US.UTF-8 UTF-8\nen_IE.UTF-8 UTF-8" \
    | sudo tee /etc/locale.gen >/dev/null

run sudo locale-gen

section 'Installing packages'
run sudo pacman -Syu --noprogressbar --noconfirm --quiet reflector
run sudo reflector --save /etc/pacman.d/mirrorlist \
    --country NL \
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

section 'Configuring Rust'
run rustup install stable
run rustup component add rust-src rust-analyzer clippy rustfmt

section 'Installing AUR packages'
run yay -Syu --noprogressbar --noconfirm --needed --quiet --mflags --nocheck \
    $aur

run yay -Scc --noconfirm --quiet

section 'Configuring pacman hooks'
run sudo cp $dir/dotfiles.hook /usr/share/libalpm/hooks/
run sudo cp $dir/dotfiles_hook.sh /usr/share/libalpm/scripts/
run sudo chown root:root /usr/share/libalpm/{hooks,scripts}/dotfiles*

section 'Configuring dotfiles'
rm -rf ~/.config/fish
run stow -R dotfiles -t ~/
source ~/.config/fish/config.fish

section 'Configuring Ruby'
run ruby-install --jobs 4 --no-install-deps --no-reinstall $ruby_version
run rm -rf ~/src
echo ruby-$ruby_version >~/.ruby-version
echo 'gem: --no-document' >~/.gemrc
rbv ruby-$ruby_version
run gem update --system --silent
run gem install --silent pry pry-doc pry-theme

if ! test -f ~/.config/ivm/version
    section 'Configuring Inko'
    run ivm install latest
    run ivm default (ivm list)
    run ivm clean
end
