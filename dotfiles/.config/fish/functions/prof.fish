function prof -d 'Profile a program using samply'
    samply record -r 10000 $argv
    rm profile.json.gz
end
