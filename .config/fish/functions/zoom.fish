function zoom
    firejail \
        --quiet \
        --profile=~/.config/firejail/zoom.profile \
        --private=/opt/zoom/home /opt/zoom/ZoomLauncher
end
