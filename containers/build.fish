#!/usr/bin/env fish

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

mkdir -p $home_dir
ln --symbolic --force --no-dereference $HOME/Projects $home_dir/Projects
ln --symbolic --force --no-dereference $HOME/Downloads $home_dir/Downloads

distrobox create --image $image --name $name --home $home_dir --pull --no-entry
distrobox enter $name -- fish containers/$name/install.fish
distrobox stop --yes $name
