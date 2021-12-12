function brightness
    echo $argv | tee /sys/class/backlight/ddcci9/brightness
end
