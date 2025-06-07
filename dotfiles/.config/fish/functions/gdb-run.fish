function gdb-run --wraps=gdb --description 'Run a program under GDB'
    command gdb --eval-command=r --eval-command=bt $argv
end
