function youtube-listen -d 'Streams a YouTube video with only audio'
    mpv $argv[1] --no-video --volume=100 --cache=4096 --quiet 2>&1 >/dev/null
end

