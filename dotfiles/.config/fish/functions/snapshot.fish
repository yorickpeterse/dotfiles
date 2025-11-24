function snapshot -d 'Create a btrfs snapshot'
    set vol $argv[1]
    set name $argv[2]

    if [ $vol = / ]
        set snapshot /var/snapshots/root/$name
    else
        set snapshot /var/snapshots$vol/$name
    end

    sudo btrfs subvolume snapshot -r $vol $snapshot
end
