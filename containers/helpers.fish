function run
    set show "$argv"
    set limit 120

    if test (string length "$show") -gt $limit
        set show (string sub "$show" --length $limit) '[...]'
    end

    echo -n -e "\e[33;1mRUN\e[0m $show"

    if set output (eval $argv 2>&1)
        echo -e " \e[32;1mOK\e[0m"
    else
        echo -e " \e[31;1mERROR\e[0m"
        echo -e $output
        exit 1
    end
end

function section
    echo -e "\n\e[1m$argv\e[0m"
end

function install_rust
    section 'Configuring Rust'
    run rustup install stable
    run rustup component add rust-src rust-analyzer clippy rustfmt
    cp containers/cargo-config.toml ~/.cargo/config.toml
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
    if ! test -f ~/.config/ivm/version
        section 'Configuring Inko'
        run ivm install latest
        run ivm default (ivm list)
        run ivm clean
    end
end
