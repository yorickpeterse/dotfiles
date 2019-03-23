if exists('g:GuiLoaded')
    GuiFont Source Code Pro:h7.5:l
    GuiTabline 0
    GuiPopupmenu 0
    GuiLinespace 1

    " Hack to work around https://github.com/equalsraf/neovim-qt/issues/259
    tnoremap <S-Backspace> <Backspace>
    tnoremap <S-Space> <Space>
    tnoremap <C-Backspace> <Backspace>
    tnoremap <C-Space> <Space>
endif
