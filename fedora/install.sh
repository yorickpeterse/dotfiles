#!/usr/bin/env bash

set -e

for repo in $(cat /dnf/coprs.txt)
do
    dnf copr enable --assumeyes --quiet "$repo" >/dev/null
done

dnf install --assumeyes --quiet $(< /dnf/install.txt) >/dev/null
dnf remove --assumeyes --quiet $(< /dnf/remove.txt) >/dev/null
