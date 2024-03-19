function pkg --wraps=dnf --description 'The system package manager'
    sudo dnf5 $argv
end
