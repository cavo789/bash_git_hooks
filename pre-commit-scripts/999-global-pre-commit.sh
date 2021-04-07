#!/bin/bash

# Git pre-commit hooks. https://github.com/cavo789/bash_git_hooks/
#
# Call the global git pre-commit hooks
#
# Please read https://github.com/cavo789/bash_git_hooks#install for installation guide

if [[ -f ".git/hooks/pre-commit-scripts" ]]; then
    type realpath >/dev/null 2>&1 || {
        echo >&2 "NOTE: the realpath binary is required to chain to the repo-specific pre-commit hook. Ignoring."
        exit 0
    }
    if [[ "$(realpath "${BASH_SOURCE[0]}")" != "$(realpath ".git/hooks/pre-commit-scripts")" ]]; then
        .git/hooks/pre-commit-scripts
        exit $?
    fi
fi
