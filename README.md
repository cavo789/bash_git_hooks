# bash_git_hooks

![Banner](./banner.svg)

## Install

```bash
curl -fL -o .git/hooks/pre-commit https://raw.githubusercontent.com/cavo789/bash_git_hooks/main/pre-commit
chmod +x .git/hooks/pre-commit

mkdir -p .git/hooks/pre-commit-scripts

curl -fL -o .git/hooks/pre-commit-scripts/010-not-on-specific-branches.sh https://raw.githubusercontent.com/cavo789/bash_git_hooks/main/pre-commit/010-not-on-specific-branches.sh
chmod +x .git/hooks/pre-commit-scripts/010-not-on-specific-branches.sh

curl -fL -o .git/hooks/pre-commit-scripts/999-global-pre-commit.sh https://raw.githubusercontent.com/cavo789/bash_git_hooks/main/pre-commit/999-global-pre-commit.sh
chmod +x .git/hooks/pre-commit-scripts/999-global-pre-commit.sh
```
