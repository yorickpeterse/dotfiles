function rg -d 'Runs ripgrep with custom colors'
    command rg --colors 'match:bg:yellow' --colors 'match:fg:black' --colors 'match:style:nobold' --colors 'path:fg:green' --colors 'path:style:bold' --colors 'line:fg:cyan' $argv
end

