#!/bin/bash

################ DEPENDENCIES CHECK ##################
commands=(ping unbuffer feedgnuplot gnuplot)
missingCmd=()
for cmd in "${commands[@]}"; do
    if ! which $cmd 2> /dev/null 1> /dev/null; then
        missingCmd+=("$cmd")
    fi
done
if [ -n "$missingCmd" ]; then
    echo -e "${red}# Missing dependencies! (${missingCmd[@]})"$bold"\nThe script will not run properly.${fontreset}"
    echo -e "For OSX install dependencies using 'brew install expect feedgnuplot gnuplot'"
    return 1
fi
######################################################

function graphPing() {
    if (( $# == 1 )); then
        ping $1 | unbuffer -p cut -d ' ' -f 7 | unbuffer -p cut -d '=' -f 2 | feedgnuplot --lines --stream --terminal "dumb $(tput cols),$(tput lines)" --xlen 200 --extracmds 'unset grid'
    else
        echo "Argument for host address is mandatory!"
    fi
}

graphPing $1