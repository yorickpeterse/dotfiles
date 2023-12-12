function run
    tput civis
    echo -n -e "\e[33;1mRUN\e[0m   $argv\r"
    set lines (math floor (string length "$argv") / $COLUMNS)

    if test $lines -gt 0
        tput cuu $lines
    end

    if set output ($argv 2>&1)
        echo -e "\e[32;1mOK\e[0m    $argv"
        tput cnorm
    else
        echo -e "\e[31;1mERROR\e[0m $argv"
        echo -e $output
        tput cnorm
        exit 1
    end
end

function section
    echo -e "\n\e[1m$argv\e[0m"
end

trap 'tput cnorm' EXIT INT
