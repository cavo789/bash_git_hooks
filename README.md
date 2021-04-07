# bash_git_hooks

![Banner](./banner.svg)

## Install

From a bash shell, go to your local repository (let's say `~/repository/project_one`) and run this command: 

```bash
curl -fL -o /tmp/hooks_install.sh https://raw.githubusercontent.com/cavo789/bash_git_hooks/main/install.sh
chmod +x /tmp/hooks_install.sh
/tmp/hooks_install.sh
```

This will download the install.sh script to the `/tmp` folder, make it executable and run it.

You'll be prompted if you want to install hooks for the current repository or globally.
