#!/usr/bin/env fish

set packages (sudo dnf repoquery --qf '%{name}' --userinstalled)
set coprs (sudo dnf copr list --enabled)

echo "echo 'Configuring dnf...'"
echo "echo 'max_parallel_downloads=10' | sudo tee --append /etc/dnf/dnf.conf >/dev/null"

for line in $coprs
    echo "echo 'Enabling $line...'"
    echo "sudo dnf copr enable --assumeyes $line >/dev/null 2>&1"
end

echo "echo 'Installing packages...'"
echo "sudo dnf install --assumeyes --quiet $packages"
echo "sudo dnf update --assumeyes --quiet"
