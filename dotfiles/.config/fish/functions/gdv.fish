function gdv -d 'Run `git diff` using NeoVim'
    # This gets the ID of the last tab. We then use this ID to open all files
    # after that tab.
    if test -n "$NVIM_LISTEN_ADDRESS"
        set tabid (nvr -s --remote-expr 'tabpagenr("$")')
    else
        set tabid 1
    end

    set files (git diff --name-only --diff-filter=AM $argv)

    if ! set -q files[1]
        echo 'No files have been added or changed'
        return
    end

    # This will be the ID of the tab to jump to after opening all files.
    set goto_tabid (math "$tabid + 1")

    # This opens all added or modified files like so:
    #
    # 1. Open all files in a new tab
    # 2. For these newly opened tabs (and only those tabs), show a diff
    # 3. Go to the first tab we opened
    nvr -s -p $files \
        -c "tabn $goto_tabid" \
        +"$tabid,tabdo Gdiffsplit $argv"
end
