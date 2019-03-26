if exists('g:GuiLoaded')
    GuiFont Source Code Pro:h7.5:l
    GuiTabline 0
    GuiPopupmenu 0
    GuiLinespace 1

    " Mouse settings, mostly so copy-pasting in :term buffers is a bit easier
    set mouse=a
    set mousemodel=popup

    " neovim-qt renders fonts slightly differently on my desktop, likely due to
    " different display dimensions.
    if hostname() == 'sharkie'
        GuiFont Source Code Pro:h7.5
        GuiLinespace 2
    end

    " Hack to work around https://github.com/equalsraf/neovim-qt/issues/259
    tnoremap <S-Backspace> <Backspace>
    tnoremap <S-Space> <Space>
    tnoremap <C-Backspace> <Backspace>
    tnoremap <C-Space> <Space>
endif
