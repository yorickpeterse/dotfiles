function gss
    git show -1 --format='' $argv | ydiff -s
end
