function brightness
    if test -d /sys/class/backlight/intel_backlight
        set max (cat /sys/class/backlight/intel_backlight/max_brightness)
        set new_value (math "round($argv[1] * ($max / 100))")

        echo $new_value | tee /sys/class/backlight/intel_backlight/brightness
    else
        ddcutil setvcp 0x10 $argv[1]
    end
end
