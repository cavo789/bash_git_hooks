#!/bin/bash

# Git pre-commit hooks. https://github.com/cavo789/bash_git_hooks/
#
# Stops accidental commits to master and dev branches.
#
# Install:
#
# cd path/to/git/repo
# mkdir -p .git/hooks/pre-commit
# curl -fL -o .git/hooks/pre-commit/010-not-on-specific-branches.sh https://raw.githubusercontent.com/cavo789/bash_git_hooks/main/pre-commit/010-not-on-specific-branches.sh
# chmod +x .git/hooks/pre-commit/010-not-on-specific-branches.sh

BRANCH=`git rev-parse --abbrev-ref HEAD`

# Don't allow to commit directly on these branches
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" || "$BRANCH" == "dev" ]]; then
  echo "You are on branch $BRANCH. Are you sure you want to commit to this branch?"
  echo "If so, commit with the --no-verify parameter to bypass this pre-commit hook."
  exit 1
fi

exit 0
