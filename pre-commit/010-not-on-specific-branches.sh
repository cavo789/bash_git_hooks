#!/bin/bash

BRANCH=`git rev-parse --abbrev-ref HEAD`

# Don't allow to commit directly on master or dev
if [[ "$BRANCH" == "master" || "$BRANCH" == "dev" ]]; then
  echo "You are on branch $BRANCH. Are you sure you want to commit to this branch?"
  echo "If so, commit with the --no-verify parameter to bypass this pre-commit hook."
  exit 1
fi

exit 0
