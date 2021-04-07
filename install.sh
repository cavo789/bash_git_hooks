#!/bin/bash

# Base URL of our git bash hooks repo
REMOTE="https://raw.githubusercontent.com/cavo789/bash_git_hooks/main"

# Declare an array with the list of scripts present in the repository
declare -a arrScripts=("010-not-on-specific-branches.sh" "999-global-pre-commit.sh")

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
read -r -p "Do you want install hooks globally (Yes means for all repositories) or only for this repo? [Y/n]:" yesno

# Transform to lowercase
yesno="${yesno,,}"

if [[ "$yesno" == "y" || "$yesno" == "" ]]; then
    # Globally
    LOCAL="$(realpath ~)/.git/hooks"
    mkdir -p "$LOCAL"

    git config --global core.hooksPath "$LOCAL"
else
    # Only for this repo
    LOCAL="$PWD/.git/hooks"
fi

printf "\n\n\e[1;32m%s\e[m\n" "Install hooks in $LOCAL"

# Get the pre-commit hook
printf "\n\e[1;33m%s\e[m" "Download the pre-commit hook"

printf "\n\e[1;34m%s\e[m" "    Get the pre-commit bash script"

curl -fL -o "$LOCAL/pre-commit" "$REMOTE/pre-commit" --no-progress-meter
chmod +x "$LOCAL/pre-commit"

# Now, download each scripts from the REMOTE to the LOCAL folder
LOCAL_SCRIPTS="$LOCAL/pre-commit-scripts"
REMOTE_SCRIPTS="$REMOTE/pre-commit-scripts"

# Create the local folder
mkdir -p "$LOCAL_SCRIPTS"

printf "\n\e[1;34m%s\e[m" "    Download pre-commit scripts"

# Download scripts
for script in "${arrScripts[@]}"; do
    printf "\n\e[1;36m%s\e[m" "        Download $script"

    curl -fL -o "$LOCAL_SCRIPTS/$script" "$REMOTE_SCRIPTS/$script" --no-progress-meter
    chmod +x "$LOCAL_SCRIPTS/$script"
done

printf "\n\n\e[1;32m%s\e[m\n" "Hooks successfully installed."
printf "\e[1;32m%s\e[m\n\n" "From now, each time you'll run git commit, hooks in $LOCAL_SCRIPTS will be triggered."
