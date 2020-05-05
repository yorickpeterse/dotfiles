function zoom
    env HOME=/opt/zoom/home firejail \
        --quiet \
        --profile=~/.config/firejail/zoom.profile \
        /opt/zoom/ZoomLauncher
end
