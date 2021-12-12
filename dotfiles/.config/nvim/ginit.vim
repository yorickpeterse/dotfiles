" Mouse settings, mostly so copy-pasting in :term buffers is a bit easier
set mouse=a
set mousemodel=popup

" neovim-gtk
if exists('g:GtkGuiLoaded')
  call rpcnotify(1, 'Gui', 'Font', 'Source code Pro 8')
  call rpcnotify(1, 'Gui', 'Linespace', '0')
  call rpcnotify(1, 'Gui', 'Option', 'Popupmenu', 0)
  call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0)
  call rpcnotify(1, 'Gui', 'Command', 'SetCursorBlink', '0')
end
