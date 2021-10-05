#!/bin/bash
source add_color.sh

################ DEPENDENCIES CHECK ##################
commands=(date cmatrix)
missingCmd=()
for cmd in "${commands[@]}"; do
    if ! which $cmd 2> /dev/null 1> /dev/null; then
        missingCmd+=("$cmd")
    fi
done
if [ -n "$missingCmd" ]; then
    printf $red"# Missing dependencies! (${missingCmd[@]})"$bold"\nThe script will not run properly.\n"$fontreset
    exit 1
fi
######################################################

totalLoad=5
while (( $totalLoad > 0 )); do
    loader+=" ."; echo -ne "[Entering MATRIX in $totalLoad] $loader\r"
    (( totalLoad-- ))
    sleep 1
done
cmatrix