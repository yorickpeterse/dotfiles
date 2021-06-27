if exists('g:GuiLoaded')
    GuiFont Source Code Pro:h7.5
    GuiTabline 0
    GuiPopupmenu 0
    GuiLinespace 1
    GuiRenderLigatures 1

    " Mouse settings, mostly so copy-pasting in :term buffers is a bit easier
    set mouse=a
    set mousemodel=popup

    " Hack to work around https://github.com/equalsraf/neovim-qt/issues/259
    tnoremap <S-Backspace> <Backspace>
    tnoremap <S-Space> <Space>
    tnoremap <C-Backspace> <Backspace>
    tnoremap <C-Space> <Space>
    tnoremap <C-Enter> <Enter>
endif
