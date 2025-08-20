#!/usr/bin/env fish

set -x TERM xterm-256color
source containers/helpers.fish

set name $argv[1]

section 'Building image'
run podman build -t $name-dev -f containers/$name/Containerfile containers/$name

section 'Creating container'
run echo y \| toolbox create --image $name-dev $name

cd containers/$name
test -f install.fish && toolbox run --container $name fish install.fish
cd ..

section Finishing
run podman stop $name
