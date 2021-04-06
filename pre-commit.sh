#!/bin/bash

HOOK="pre-commit"

# Get the alphabetical list of $HOOK hooks and run them one by one.
# As soon as one hook failed, the $HOOK hook will fails and the commit
# action will be aborted.

# Folder containing this script
CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Loop
for FILE in `ls $CURDIR/$HOOK/ | sort -g`; 
do
    # Get full path
    FILE=$(realpath $CURDIR/$HOOK/$FILE)

    printf "\e[1;30m%s\e[m\n" "Process $FILE" >&1 

    OUTPUT=`/bin/bash $FILE`

    if [ $? -ne 0 ]; then
        # Don't execute the next hook if this one has failed
        printf "\n\e[1;91m%s\e[m\n" "ERROR! The $FILE has failed with the following error:" >&2
        printf "\n\e[1;91m%s\e[m\n" "$OUTPUT"
        printf "\n\e[1;91m%s\e[m\n" "The current git action is aborted." >&2
        exit 1
    fi
done

printf "\n\e[1;92m%s\e[m\n" "${BASH_SOURCE[0]} Success!"

exit 0