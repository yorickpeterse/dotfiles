function run
    echo -n "$argv"

    if set output ($argv 2>&1)
        echo -e ": \e[32mOK\e[0m"
    else
        echo -e ": \e[31mERROR\e[0m"
        echo -e $output
        exit 1
    end
end

function section
    echo -e "\n\e[1m$argv\e[0m"
end
