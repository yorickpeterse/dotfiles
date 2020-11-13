function gdv
    nvr -s -p (git diff --name-only $argv) +"tabdo Gdiffsplit $argv" +tabfirst
end
