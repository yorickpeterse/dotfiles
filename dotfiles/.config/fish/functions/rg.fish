function rg -d 'Runs ripgrep with custom colors'
    command rg \
        --colors 'match:none' \
        --colors 'match:fg:black' \
        --colors 'match:bg:242,222,145' \
        --colors 'path:none' \
        --colors 'path:style:bold' \
        --colors 'column:none' \
        --colors 'line:fg:blue' $argv
end
