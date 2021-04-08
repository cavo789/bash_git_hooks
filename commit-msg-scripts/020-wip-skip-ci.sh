#!/bin/bash

# Git commit-msg hooks. https://github.com/cavo789/bash_git_hooks/
#
# If the commit message start with "WIP:", this script will add the [skip ci]
# line in the .git/COMMIT_EDITMSG file. The presence of that keyword will indicate
# to skip the pipeline
#
# Please read https://github.com/cavo789/bash_git_hooks#install for installation guide

if grep -q -i -e "WIP:" "$1"; then
    # Append the .git/COMMIT_EDITMSG file and add a new line with, only,
    # [skip ci]
    printf "\e[1;30m%s\e[m\n" "    Commit message starting with WIP so append the [skip ci] keyword in $1" >&1
    echo "[skip ci]" >>"$1"
fi
