function rg -d 'Runs ripgrep with custom colors'
    command rg \
        --colors 'match:fg:yellow' \
        --colors 'match:style:bold' \
        --colors 'path:fg:blue' \
        --colors 'path:style:bold' \
        --colors 'column:fg:cyan' \
        --colors 'line:fg:cyan' $argv
end

