function perf-to-flame -d 'Converts perf output to a flamegraph'
    set input $argv[1]
    set name (basename $input)
    set flamegraph ~/Projects/perl/flamegraph
    set folded /tmp/$name.perf-folded
    set svg /tmp/$name.svg

    perf script | eval "$flamegraph/stackcollapse-perf.pl" > $folded

    grep -v '\[unknown\]' $folded | eval "$flamegraph/flamegraph.pl" > $svg

    rm /tmp/$name.perf-folded

    echo "Wrote SVG to $svg"
end
