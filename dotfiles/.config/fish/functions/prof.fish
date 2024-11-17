function prof -d 'Profile a program using perf'
    perf record -g --call-graph dwarf -F 10000 $argv
end
