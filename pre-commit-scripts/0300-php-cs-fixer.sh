#!/bin/bash

# Git pre-commit hooks. https://github.com/cavo789/bash_git_hooks/
#
# Run php-cs-fixer in dry-run and notify the user is php-cs-fixer has made
# a change. If so, the git commit action will be failed and the user will
# be invited to run php-cs-fixer to fix the problem.
#
# Please read https://github.com/cavo789/bash_git_hooks#install for installation guide

# Make sure php-cs-fixer.phar is installed
command=$(which php-cs-fixer.phar)

if [[ -z $command ]]; then
    exit 0
fi

# Ok, make sure we've our configuration file.
if [[ ! -f ".config/.php_cs" ]]; then
    printf "\n\e[1;91m%s\e[m\n" "The .config/.php_cs configuration file for PHP-CS-FIXER is missing; stop" >&2
    exit 1
fi

# Create a temporary file and redirect php-cs-fixer output in that file
TMP=$(mktemp)

# .config/.php_cs is present in the root folder of the repository
CLI="$command fix --dry-run --config=.config/.php_cs --diff"

printf "\e[1;30m%s\e[m\n" "Run $CLI (output redirected to $TMP)" >&1

# Run php-cs-fixer
$CLI >"$TMP"

# Remember the exit code of php-cs-fixer
exitCode=$?

# shellcheck disable=SC2181
if [[ "$exitCode" -gt 0 ]]; then
    printf "\n\e[1;91m%s\e[m\n" "PHP-CS-FIXER has returned the following error code $exitCode" >&1
    printf "\e[1;91m%s\e[m\n\n" "If needed, you can consult the $TMP file for more info" >&1
    printf "\e[1;93m%s\e[m\n" "To solve this issue, just run $command fix --config=.config/.php_cs" >&1
    exit $exitCode
fi
