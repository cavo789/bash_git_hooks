# bash_git_hooks

![Banner](./banner.svg)

## Install

```bash
curl -fL -o .git/hooks/pre-commit.sh https://raw.githubusercontent.com/cavo789/bash_git_hooks/main/pre-commit.sh
chmod +x .git/hooks/pre-commit.sh

mkdir -p .git/hooks/pre-commit

curl -fL -o .git/hooks/pre-commit/010-not-on-specific-branches.sh https://raw.githubusercontent.com/cavo789/bash_git_hooks/main/pre-commit/010-not-on-specific-branches.sh
chmod +x .git/hooks/pre-commit/010-not-on-specific-branches.sh

curl -fL -o .git/hooks/pre-commit/999-global-pre-commit.sh https://raw.githubusercontent.com/cavo789/bash_git_hooks/main/pre-commit/999-global-pre-commit.sh
chmod +x .git/hooks/pre-commit/999-global-pre-commit.sh
```
