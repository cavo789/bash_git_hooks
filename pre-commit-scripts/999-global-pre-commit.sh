#!/bin/bash

# Git pre-commit hooks. https://github.com/cavo789/bash_git_hooks/
#
# Call the global git pre-commit hooks
#
# Install:
# cd path/to/git/repo
# mkdir -p .git/hooks/pre-commit-scripts
# curl -fL -o .git/hooks/pre-commit-scripts/999-global-pre-commit.sh https://raw.githubusercontent.com/cavo789/bash_git_hooks/main/pre-commit/999-global-pre-commit.sh
# chmod +x .git/hooks/pre-commit-scripts/999-global-pre-commit.sh

if [[ -f ".git/hooks/pre-commit" ]]; then
  type realpath >/dev/null 2>&1 || { echo >&2 "NOTE: the realpath binary is required to chain to the repo-specific pre-commit hook. Ignoring."; exit 0; }
  if [[ "$(realpath "${BASH_SOURCE[0]}")" != "$(realpath ".git/hooks/pre-commit")" ]]; then
    .git/hooks/pre-commit
    exit $?
  fi
fi

exit 0
