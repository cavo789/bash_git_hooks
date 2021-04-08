#!/bin/bash

# Git pre-commit hooks. https://github.com/cavo789/bash_git_hooks/
#
# Run PHP Code Style (PHPCS) tool, detect if there are errors in the file
# If yes, run PHP Code Beautifier (PHPCBF) to try to solve them automatically
# (somes errors can be fixed thanks to PHPCBF). Run PHPCS once more after the fix
# to detect if there are still errors.
#
# If errors were detected:
#   - if errors were autofixed, the developer just need to commit again
#   - if errors still stay, the developer will need to fix them manually
#
#! For performance reasons, only files in the staging area will be processed
#! by this hook. This means that previoulsy commited files won't be analysed
#! and this is fine, we just want to work on ours, not the entire repo, not
#! the file of other developers (or legacy files).
#
# Please read https://github.com/cavo789/bash_git_hooks#install for installation guide

# Full path to phpcbf.phar and phpcs.phar, will be initialized in the prerequisites function
PHPCBF_BINARY=""
PHPCS_BINARY=""

# Default location for the configuration file for phpcbf
CONFIGURATION=".config/phpcs.xml"

# Array with the list of files in the staging area and how many they are
STAGED_FILES=()
STAGED_FILES_COUNT=0

# region-docblock
# Make sure this hook has to be fired i.e.
#    - No files in the staging area? Nothing to do.
#    - phpcbf is not installed? Nothing to do.
#    - phpcbf is installed but config file is missing? This is an error
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

    # Make sure tools are installed
    PHPCBF_BINARY=$(which phpcbf.phar)
    PHPCS_BINARY=$(which phpcs.phar)

    # Both should be there
    if [ -z "$PHPCBF_BINARY" ] || [ -z "$PHPCS_BINARY" ]; then
        exit 0
    fi

    # Ok, make sure we've our configuration file.
    if [[ ! -f "$CONFIGURATION" ]]; then
        printf "\n\e[0;31m%s\e[m\n" "The $CONFIGURATION configuration file for phpcbf is missing; stop" >&2
        exit 1
    fi
}

# region-docblock
# Display the result
# endregion
function showStatus() {
    errorsFound=$1 # Number of files with unfixable errors; requiring manual actions
    filesFixed=$2  # Number of files automatically fixed; don't contains errors anymore

    if [[ $errorsFound -gt 0 ]]; then
        printf "\n\e[0;31m%s\e[m\n" "PHP Codestyle found errors or warnings and could not fix all of them!" >&2
        printf "\n\e[0;31m%s\e[m\n" "Try to fix them and commit again." >&2
        exit 1
    fi

    if [[ $filesFixed -gt 0 ]]; then
        printf "\n\e[0;31m%s\e[m\n" "PHPCBF has fixed some coding style errors for you." >&2
        printf "\e[1;93m%s\e[m\n" "Please git commit again to take the updated version in your commit." >&2
        exit 1
    fi
}

# region-entrypoint
prerequisites

# Create a temporary file and redirect phpcbf output in that file
TMP=$(mktemp)

PHPCS_CLI="$PHPCS_BINARY -p -v --standard=$CONFIGURATION"
PHPCBF_CLI="$PHPCBF_BINARY -p -v --standard=$CONFIGURATION"

filesFixed=0
errorsFound=0

# Run PHPCS/PHPCBF only on staged files; not the entire repo
for stagedFile in "${STAGED_FILES[@]}"; do
    if [[ "$stagedFile" == *.php ]] && [ -f "$stagedFile" ]; then
        # Run PHP Code Style Check (PHPCS) and determine if there are things to solve
        $PHPCS_CLI "$stagedFile" >"$TMP"
        exitCode=$?

        if [ $exitCode -eq 0 ]; then
            # PHPCS don't detect coding style error, fine, skip to next file.
            continue
        fi

        # Run PHP Code Beautifier (try to autofix errors) then Style Check again
        $PHPCBF_CLI "$stagedFile" >"$TMP"
        $PHPCS_CLI "$stagedFile" >"$TMP"

        # Still errors ? Ok, there were unfixed errors
        exitCode=$?

        if [ $exitCode -eq 0 ]; then
            # File had some issues but they were automatically fixed.
            # That file can be commited again and it's fine
            printf "\e[0;37m%s\e[m\n" "    Fixable coding style errors detected in $stagedFile" >&1
            printf "\e[0;37m%s\e[m\n" "    CLI was \"$PHPCBF_CLI $stagedFile\"" >&1
            ((filesFixed++))
        else
            # Oups. The error stay so not automatically fixable.
            # The commit can't be made for that file
            printf "\e[1;91m%s\e[m\n" "    Unfixable coding style errors detected in $stagedFile" >&1
            printf "\e[1;30m%s\e[m\n" "    CLI was \"$PHPCBF_CLI $stagedFile\"" >&1
            ((errorsFound++))
        fi
    fi
done

showStatus "$errorsFound" "$filesFixed"
# endregion
