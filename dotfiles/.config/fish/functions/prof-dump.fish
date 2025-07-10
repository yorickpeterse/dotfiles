function prof-dump -d 'Export Perf data for the Firefox profiler'
    perf script -F +pid >/tmp/perf.firefox.data
    rm perf.data
end
