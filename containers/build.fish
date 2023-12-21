#!/usr/bin/env fish

source containers/helpers.fish

if [ $argv[1] = '' ]
    echo 'The first argument must be the container name'
    exit 1
end

if [ $argv[2] = '' ]
    echo 'The second argument must be the image name'
    exit 1
end

set name $argv[1]
set image $argv[2]
set home_dir $HOME/homes/$name
set install containers/$name/install.fish

section 'Setting up directories'
run mkdir -p $home_dir
run ln --symbolic --force --no-dereference $HOME/Projects $home_dir/Projects
run ln --symbolic --force --no-dereference $HOME/Downloads $home_dir/Downloads

section 'Creating container'
run distrobox create --image $image --name $name --home $home_dir --pull --no-entry

if test -f $install
    section 'Configuring container'
    distrobox enter $name -- fish $install
end

section Finishing
run distrobox stop --yes $name
