#!/bin/bash

function singleton() {
    [ -f $0.pid ] && pid="$(cat $0.pid)"
    # echo Old PID: $pid
    # echo New PID: $$
    if [ -n "$pid" ] && kill -0 $pid 2> /dev/null 1> /dev/null; then
        echo -e "${red}Another instance is running (PID: $pid)${fontreset}"
        return 1
    else
        # write PID file
        echo $$ > $0.pid
        return 0
    fi
}

function finish() {
    echo "Removing lock file..."
    [ -f $0.pid ] && rm $0.pid
}
trap finish SIGINT

# MAIN
singleton || exit 1

sec="15"
echo "Sleeping for $sec seconds..."
sleep $sec
finish