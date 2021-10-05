#!/bin/bash

################ DEPENDENCIES CHECK ##################
commands=(bc awk)
missingCmd=()
for cmd in "${commands[@]}"; do
    if ! which $cmd 2> /dev/null 1> /dev/null; then
        missingCmd+=("$cmd")
    fi
done
if [ -n "$missingCmd" ]; then
    echo -e "# Missing dependencies! (${missingCmd[@]})\nThe script will not run properly."
    exit 1
fi
######################################################


# Pushover Notifications
function pushover() {
    # echo -e "\n$message"
    curl -s -F "token=" \
    -F "user=" \
    -F "title="diskspace"" \
    -F "message=$message" \
    -F "priority=$priority" \
    https://api.pushover.net/1/messages.json
}

function diskspace {
    local server=$(hostname)
    local threshold="10" # %free space limit
    local mountpoint="/"
    local priority=0

    # diskspace
    local MOUNT_free=`echo "100-$(df -P $mountpoint | grep $mountpoint | awk '{print $5}' | sed 's/%//g')" | bc` # free space on /
    dmessage="diskspace: $MOUNT_free% free"

    if (( $MOUNT_free < $threshold )); then    
        local priority=1
        echo -e $dmessage" ... WARNING"
    else
        echo -e $dmessage" ... OK"
    fi

    # inodes
    if [[ $(uname -s) == "Darwin" ]]; then # MAC OS
        local INODE_free=`echo "100-$(df -i $mountpoint | grep $mountpoint | awk '{print $8}' | sed 's/%//g')" | bc`
    else # LINUX
        local INODE_free=`echo "100-$(df -i $mountpoint | grep $mountpoint | awk '{print $5}' | sed 's/%//g')" | bc`
    fi
    imessage="inode: $INODE_free% free"

    if (( $INODE_free < $threshold )); then
        local priority=1
        echo -e $imessage" ... WARNING"
    else
        echo -e $imessage" ... OK"
    fi

    # build message and trigger notification
    (( $priority == 1 )) && message="`echo -e "$(date)\nSERVER: $server\n\n$dmessage\n$imessage"`" && return 0
}

diskspace && pushover