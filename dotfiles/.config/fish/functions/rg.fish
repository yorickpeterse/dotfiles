function rg -d 'Runs ripgrep with custom colors'
    command rg \
        --colors 'match:none' \
        --colors 'match:fg:yellow' \
        --colors 'match:style:bold' \
        --colors 'match:style:underline' \
        --colors 'path:none' \
        --colors 'path:style:bold' \
        --colors 'column:none' \
        --colors 'line:fg:blue' $argv
end
