#!/usr/bin/env fish

set -x TERM xterm-256color
source containers/helpers.fish

set image dev
set name fedora

section 'Building image'
run podman build -t dev -f containers/Containerfile containers

section 'Creating container'
run echo y \| toolbox create --image $image $name

toolbox run --container $name fish containers/install.fish

section Finishing
run podman stop $name
