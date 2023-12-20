#!/usr/bin/env fish

source containers/helpers.fish

set name dev
set image archlinux

section 'Creating container'
run distrobox create --image $image --name $name --pull --no-entry

section 'Configuring container'
distrobox enter $name -- fish containers/$name/install.fish

section Finishing
run distrobox stop --yes $name
