# Set up the dotfiles
dotfiles:
    fish dotfiles.fish

# Provision a new Fedora Workstation installation
fedora:
    fish fedora/setup.fish

# Build a Fedora packaging container
fedora-rpm:
    fish containers/build.fish fedora-rpm

# Build a QMK container
qmk:
    fish containers/build.fish qmk
