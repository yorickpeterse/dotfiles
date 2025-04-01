function prof-dump -d 'Convert perf.data to a format for the Firefox Profiler'
    perf script -F +pid >perf.firefox.data
end
