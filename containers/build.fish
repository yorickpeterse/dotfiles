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

# The directories in $HOME to link into the container.
set link Documents Downloads Projects

section 'Setting up directories'
run mkdir -p $home_dir

for dir in $link
    run ln --symbolic --force --no-dereference $HOME/$dir $home_dir/$dir
end

section 'Creating container'
run distrobox create --image $image --name $name --home $home_dir --pull --no-entry

if test -f $install
    section 'Configuring container'

    # Make sure we're running the rest from the container's version of the
    # dotfiles, such that symbolic links remain consistent.
    cd $home_dir/Projects/general/dotfiles
    distrobox enter $name -- fish $install
end

section Finishing
run distrobox stop --yes $name
