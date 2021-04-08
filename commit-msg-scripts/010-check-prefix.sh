#!/bin/bash

# Git commit-msg hooks. https://github.com/cavo789/bash_git_hooks/
#
# If the commit message start with "WIP:", this script will add the [skip ci]
# line in the .git/COMMIT_EDITMSG file. The presence of that keyword will indicate
# to skip the pipeline
#
# Please read https://github.com/cavo789/bash_git_hooks#install for installation guide

# Get the content of the commit message ($1 has been initialized by git to .git/COMMIT_EDITMSG)
commitMessage=$(cat "$1")

# Extract the first word of the message, this is the prefix (f.i. "FIX:")
commitPrefix=$(echo "$commitMessage" | head -n1 | cut -d " " -f1)

# Force the prefix to uppercase("wip:" will become "WIP:")
commitPrefix=${commitPrefix^^}

# List of required prefix; the message should start with one of these prefix
declare -A arrPrefixes=(
    [CHORE:]="Small changes in the code like a refactoring"
    [FEAT:]="You've added a new feature"
    [FIX:]="You've fixed an issue"
    [WIP:]="Work in progress"
)

FOUND=false
for prefix in "${!arrPrefixes[@]}"; do
    if [[ "$prefix" == "$commitPrefix" ]]; then
        FOUND=true
    fi
done

if ! $FOUND; then
    printf "\e[1;31m%s\e[m\n" "    Your commit message doesn't contains a valid prefix" >&1
    printf "\e[1;31m%s\e[m\n" "    Please use one of the prefix below when commiting" >&1

    for prefix in "${!arrPrefixes[@]}"; do
        printf "\e[1;36m%s\e[m\n" "    Use prefix \"$prefix\" --> ${arrPrefixes[$prefix]}"
    done

    exit 1
fi
