#!/bin/bash

# Git pre-commit hooks. https://github.com/cavo789/bash_git_hooks/
#
# Run phpcbf in dry-run and notify the user is phpcbf detect a change
# that can be fixed automaticall. If so, the git commit action will be failed
# and the user will be invited to run phpcs to fix the problem.
#
# Please read https://github.com/cavo789/bash_git_hooks#install for installation guide

# Make sure phpcbf.phar is installed
command=$(which phpcbf.phar)

if [[ -z $command ]]; then
    exit 0
fi

# Ok, make sure we've our configuration file.
if [[ ! -f ".config/phpcs.xml" ]]; then
    printf "\n\e[1;91m%s\e[m\n" "The .config/phpcs.xml configuration file for phpcbf is missing; stop" >&2
    exit 1
fi

# Create a temporary file and redirect phpcbf output in that file
TMP=$(mktemp)

# .config/phpcs.xml is present in the root folder of the repository
#    -p  Show progress of the run
#    -v  Print processed files
CLI="$command -p -v --standard=.config/phpcs.xml $PWD/tests/Feature"

printf "\e[1;30m%s\e[m\n" "Run $CLI (output redirected to $TMP)" >&1

# Run phpcbf
$CLI >"$TMP"

# Remember the exit code of phpcbf
exitCode=$?

# shellcheck disable=SC2181
if [[ "$exitCode" -gt 0 ]]; then
    printf "\n\e[1;91m%s\e[m\n" "PHPCBF has made some changes in your codebase" >&1
    printf "\e[1;91m%s\e[m\n\n" "You can consult the $TMP file for more info" >&1
    printf "\e[1;93m%s\e[m\n" "Since changes have been made, run 'git status' to see modified files and 'git add .' to include changes in your commit" >&1
    exit $exitCode
fi
