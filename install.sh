#!/bin/bash

# Base URL of our git bash hooks repo
REMOTE="https://raw.githubusercontent.com/cavo789/bash_git_hooks/main"
# Local folder where scripts will be stored
LOCAL=""

# region-docblock
# Private function, loop an array with filenames and download these
# files locally
# endregion
function installHook() {
    hookName="$1" # The hook name like "pre-commit"

    # Get the pre-commit hook
    printf "\n\e[1;33m%s\e[m" "Download the $hookName hook"
    printf "\n\e[1;34m%s\e[m" "    Get the $hookName bash script"

    # Create the local folder
    mkdir -p "$LOCAL"

    curl -fL -o "$LOCAL/$hookName" "$REMOTE/$hookName" --no-progress-meter
    chmod +x "$LOCAL/$hookName"
}

# region-docblock
# Private function, loop an array with filenames and download these
# files locally
# endregion
function installScripts() {
    hookName="$1"   # The hook name like "pre-commit"
    arrScripts="$2" # An array with the list of scripts to download

    # Scripts will be stored in a "xxx-scripts" folder: all scripts for the "pre-commit"
    # hook will be in the "pre-commit-scripts" folder. Same logic for the remote URL
    local="$LOCAL/$hookName-scripts"
    remote="$REMOTE/$hookName-scripts"

    printf "\n\e[1;34m%s\e[m" "    Download $hookName scripts"

    # Create the local folder
    mkdir -p "$local"

    # Download scripts
    for script in "${arrScripts[@]}"; do
        printf "\n\e[1;36m%s\e[m" "        Download $script"

        curl -fL -o "$local/$script" "$remote/$script" --no-progress-meter
        chmod +x "$local/$script"
    done
}

# region-docblock
# Install the pre-commit hooks and its multiple scripts
# endregion
function installPreCommit() {
    # Declare an array with the list of scripts present in the repository
    declare -a arrScripts=(
        "010-not-on-specific-branches.sh"
        "0300-php-cs-fixer.sh"
        "0301-phpcbf.sh"
        "999-global-pre-commit.sh"
    )

    installHook "pre-commit"
    installScripts "pre-commit" "${arrScripts[@]}"
}

# region-docblock
# Install the commit-msg hooks and its multiple scripts
# endregion
function installCommitMsg() {
    # Declare an array with the list of scripts present in the repository
    declare -a arrScripts=(
        "010-check-prefix.sh"
        "020-wip-skip-ci.sh"
    )

    installHook "commit-msg"
    installScripts "commit-msg" "${arrScripts[@]}"
}

# http://patorjk.com/software/taag/#p=display&f=Big&t=Git%20hooks
cat <<\EOF
   _____ _ _     _                 _        
  / ____(_) |   | |               | |       
 | |  __ _| |_  | |__   ___   ___ | | _____ 
 | | |_ | | __| | '_ \ / _ \ / _ \| |/ / __|
 | |__| | | |_  | | | | (_) | (_) |   <\__ \
  \_____|_|\__| |_| |_|\___/ \___/|_|\_\___/
                                            
                                            
EOF

# Get this script from his repository
# curl -fL -o install.sh $REMOTE/install.sh

# shellcheck disable=SC2034
read -r -p "Do you want install hooks for this repository (Y) or globally (n)? [Y/n]:" yesno

# Transform to lowercase
yesno="${yesno,,}"

# No means globally
if [[ "$yesno" == "n" ]]; then
    LOCAL="$(realpath ~)/.git/hooks"
    mkdir -p "$LOCAL"

    git config --global core.hooksPath "$LOCAL"
else
    # Only for this repo
    LOCAL="$PWD/.git/hooks"
fi

printf "\n\n\e[1;32m%s\e[m\n" "Install hooks in $LOCAL"

installPreCommit
installCommitMsg

printf "\n\n\e[1;32m%s\e[m\n" "Hooks successfully installed."
printf "\e[1;32m%s\e[m\n\n" "From now, each time you'll run git commit, hooks in $LOCAL_SCRIPTS will be triggered."
