cd ~/Projects/gitlab/gdk-ee
set titlestring=GitLab\ EE

tabnew +term
setlocal nonumber nornu
silent file GDK

cd ~/Projects/gitlab/gdk-ee/gitlab
new +term
setlocal nonumber nornu
silent file Terminal
tabprev
NERDTreeToggle
