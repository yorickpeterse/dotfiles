#!/usr/bin/env fish

set -x TERM xterm-256color
source containers/helpers.fish

set name fedora
set install containers/install.fish

section 'Creating container'
run echo y \| toolbox create --distro fedora $name

section 'Installing core dependencies'
run toolbox run --container $name sudo dnf install fish dnf5 dnf5-plugins --assumeyes --quiet

section 'Configuring terminal info for Ghostty'
toolbox run --container $name sudo cp -r ~/.local/share/terminfo/* /usr/share/terminfo

section 'Configuring container'
toolbox run --container $name fish $install

section Finishing
run podman stop $name
