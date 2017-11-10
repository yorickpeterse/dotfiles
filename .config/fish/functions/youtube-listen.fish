function youtube-listen -d 'Streams a YouTube video with only audio'
    mpv $argv[1] --no-video --volume=80 --cache=4096 --quiet
end

