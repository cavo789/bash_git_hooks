#!/bin/bash

# Git pre-commit hooks. https://github.com/cavo789/bash_git_hooks/
#
# Run php-cs-fixer in dry-run and notify the user is php-cs-fixer has made
# a change. If so, the git commit action will be failed and the user will
# be invited to commit again to get the latest version of the file, the one
# updated by php-cs-fixer; without any issues.
#
#! For performance reasons, only files in the staging area will be processed
#! by this hook. This means that previoulsy commited files won't be analysed
#! and this is fine, we just want to work on ours, not the entire repo, not
#! the file of other developers (or legacy files).
#
# Please read https://github.com/cavo789/bash_git_hooks#install for installation guide

# Full path to php-cs-fixer.phar, will be initialized in the prerequisites function
PHPCSFIXER_BINARY=""

# Default location for the configuration file for php-cs-fixer
CONFIGURATION=".config/.php_cs"

# Array with the list of files in the staging area and how many they are
STAGED_FILES=()
STAGED_FILES_COUNT=0

# region-docblock
# Make sure this hook has to be fired i.e.
#    - No files in the staging area? Nothing to do.
#    - php-cs-fixer is not installed? Nothing to do.
#    - php-cs-fixer is installed but config file is missing? This is an error
# endregion
function prerequisites() {
    # This will check only staged files to be commited.
    # shellcheck disable=SC2207
    STAGED_FILES=($(git diff --staged --name-only HEAD))

    # Nothing to do if nothing in the staging area
    STAGED_FILES_COUNT="${#STAGED_FILES[@]}"
    if [[ $STAGED_FILES_COUNT == 0 ]]; then
        exit 0
    fi

    # Make sure tool is installed
    PHPCSFIXER_BINARY=$(which php-cs-fixer.phar)

    if [[ -z "$PHPCSFIXER_BINARY" ]]; then
        exit 0
    fi

    # Ok, make sure we've our configuration file.
    if [[ ! -f "$CONFIGURATION" ]]; then
        printf "\n\e[0;31m%s\e[m\n" "The $CONFIGURATION configuration file for php-cs-fixer is missing; stop" >&2
        exit 1
    fi
}

# region-docblock
# Display the result
# endregion
function showStatus() {
    filesFixed=$1 # Number of files automatically fixed; don't contains issues anymore

    if [[ $filesFixed -gt 0 ]]; then
        printf "\n\e[0;31m%s\e[m\n" "PHP-CS-FIXER has fixed some coding standards issues for you." >&2
        printf "\e[1;93m%s\e[m\n" "Please git commit again to take the updated version in your commit." >&2
        exit 1
    fi
}

# region-entrypoint
prerequisites

# Create a temporary file and redirect phpcbf output in that file
TMP=$(mktemp)

PHPCSFIXER_CLI="$PHPCSFIXER_BINARY fix --config=$CONFIGURATION --diff"

filesFixed=0

# Run PHP-CS-FIXER only on staged files; not the entire repo
for stagedFile in "${STAGED_FILES[@]}"; do
    if [[ "$stagedFile" == *.php ]] && [ -f "$stagedFile" ]; then
        # Run PHP-CS-FIXER and determine if there issues to solve
        $PHPCSFIXER_CLI "--dry-run" "$stagedFile" >"$TMP" 2>&1
        exitCode=$?

        if [ $exitCode -eq 0 ]; then
            # PHP-CS-FIXER don't detect coding standards issues, fine, skip to next file.
            continue
        fi

        # Ok, now, make the change, solve the issue(s)
        $PHPCSFIXER_CLI "$stagedFile" >"$TMP" 2>&1

        # And inform the user
        printf "\e[1;31m%s\e[m\n" "    PHP coding standards issues detected and fixed in $stagedFile" >&1
        ((filesFixed++))
    fi
done

showStatus "$filesFixed"
# endregion
