trap 'tput cnorm' EXIT INT

function run
    set show "$argv"
    set limit 120

    if test (string length "$show") -gt $limit
        set show (string sub "$show" --length $limit) '[...]'
    end

    tput civis
    echo -n -e "\e[33;1mRUN\e[0m   $show\r"
    set lines (math floor (string length "$show") / $COLUMNS)

    if test $lines -gt 0
        tput cuu $lines
    end

    if set output ($argv 2>&1)
        echo -e "\e[32;1mOK\e[0m    $show"
        tput cnorm
    else
        echo -e "\e[31;1mERROR\e[0m $show"
        echo -e $output
        tput cnorm
        exit 1
    end
end

function section
    echo -e "\n\e[1m$argv\e[0m"
end

function install_locales
    section 'Setting up locale'
    run sudo cp /run/host/etc/locale.conf /etc/locale.conf
    run sudo chown root:root /etc/locale.conf
end

function install_fonts
    section 'Installing fonts'
    run ln --symbolic --force --no-dereference \
        /var/home/$USER/.local/share/fonts \
        $HOME/.local/share/fonts
end

function install_rust
    section 'Configuring Rust'
    run rustup install stable
    run rustup component add rust-src rust-analyzer clippy rustfmt
end

function install_dotfiles
    section 'Configuring dotfiles'
    run rm -rf ~/.config/fish
    run stow -R dotfiles -t ~/
    source ~/.config/fish/config.fish
end

function install_ruby
    set ver $argv[1]

    section 'Configuring Ruby'
    run ruby-install --jobs 8 --no-install-deps --no-reinstall $ver
    run rm -rf ~/src
    echo ruby-$ver >~/.ruby-version
    echo 'gem: --no-document' >~/.gemrc

    rbv ruby-$ver
    run gem update --system --silent
    run gem install --silent pry pry-doc pry-theme
end

function install_inko
    if ! test -f ~/.local/share/ivm/version
        section 'Configuring Inko'
        run ivm install latest
        run ivm default (ivm list)
        run ivm clean
    end
end
