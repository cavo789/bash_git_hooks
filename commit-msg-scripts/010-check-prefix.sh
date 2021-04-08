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
    [CHORE:]="Changes to the build process or auxiliary tools and libraries such as documentation generation"
    [DOCS:]="New documentation or updated one"
    [FEAT:]="You've added a new feature"
    [FIX:]="You've fixed an issue"
    [INIT:]="Your initial commit"
    [MERGE:]="You're merging your branch"
    [REFACTOR:]="A code change that neither fixes a bug or adds a feature"
    [STYLE:]="Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)"
    [TEST:]="Add missing tests, changes in tests files"
    [WIP:]="Work in progress"
    # This one to allow a commit like, only, the "wip" word in it
    [WIP]="Work in progress (the commit message can be, just, \"wip\", no semicolon required)"
)

FOUND=false
for prefix in "${!arrPrefixes[@]}"; do
    if [[ "$prefix" == "$commitPrefix" ]]; then
        FOUND=true
    fi
done

if ! $FOUND; then
    printf "\e[1;31m%s\e[m\n" "    Your commit message doesn't contains a valid prefix" >&1
    printf "\e[1;31m%s\e[m\n\n" "    Please use one of the prefix below when commiting" >&1

    # Loop the array. Since it's an associative array, we need to sort it first on the key
    # shellcheck disable=SC2207
    prefixes=( $( echo "${!arrPrefixes[@]}" | tr ' ' $'\n' | sort ) )

    for prefix in "${prefixes[@]}"; do
        # %-20s  means right padding 20
        printf "\e[1;36m%-20s%s\e[m\n" "        $prefix" "${arrPrefixes[$prefix]}"
    done

    exit 1
fi
