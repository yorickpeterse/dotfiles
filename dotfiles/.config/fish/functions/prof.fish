function prof -d 'Profile a program using perf'
    perf record -g --call-graph dwarf -F 10000 $argv \
        && perf script -F +pid >/tmp/perf.firefox.data \
        && rm perf.data
end
