cd ~/Projects/inko/inko/vm
set titlestring=Inko

tabnew +term
setlocal nonumber nornu
silent file VM

cd ~/Projects/inko/inko/compiler
new +term
setlocal nonumber nornu
silent file Compiler
tabprev

cd ~/Projects/inko/inko
NERDTreeToggle
