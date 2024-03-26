function run
    set show "$argv"
    set limit 120

    if test (string length "$show") -gt $limit
        set show (string sub "$show" --length $limit) '[...]'
    end

    echo -n -e "\e[33;1mRUN\e[0m $show"

    if set output (eval $argv 2>&1)
        echo -e " \e[32;1mOK\e[0m"
    else
        echo -e " \e[31;1mERROR\e[0m"
        echo -e $output
        exit 1
    end
end

function section
    echo -e "\n\e[1m$argv\e[0m"
end
