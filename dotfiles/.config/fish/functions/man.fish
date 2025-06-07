function man --wraps='man'
    if set -q NVIM
        nvr -cc tabnew -c "hide Man $argv"
    else
        command man $argv
    end
end
