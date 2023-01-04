function brightness
    if test -d /sys/class/backlight/intel_backlight
        set max (cat /sys/class/backlight/intel_backlight/max_brightness)
        set new_value (math "round($argv[1] * ($max / 100))")

        echo $new_value | tee /sys/class/backlight/intel_backlight/brightness
    else
        # My desktop display uses luminance values instead of brightness
        # percentages, in a range of 0 to 250 (inclusive).
        ddcutil setvcp 0x10 (math --scale 0 "$argv[1] * 2.5")
    end
end
