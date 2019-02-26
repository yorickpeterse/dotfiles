cd ~/Projects/gitlab/gdk-ee
set titlestring=GitLab\ EE

Tterm
stopinsert
silent file GDK

cd ~/Projects/gitlab/gdk-ee/gitlab
Term
stopinsert
res 50
silent file Terminal
tabprev

" Highlights active tabs differently, making it easier to see if I'm working on
" EE or CE.
hi TabLineSel guibg=#7965a5 guifg=white gui=bold
