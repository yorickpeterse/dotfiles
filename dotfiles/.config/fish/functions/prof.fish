function prof -d 'Profile a program using perf'
    perf record -g --call-graph dwarf -F max $argv
end
