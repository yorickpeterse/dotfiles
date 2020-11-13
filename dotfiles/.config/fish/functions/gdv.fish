function gdv -d 'Run `git diff` using NeoVim'
    nvr -s -p (git diff --name-only $argv --diff-filter=AM) \
        +"tabdo Gdiffsplit $argv" +tabfirst
end
