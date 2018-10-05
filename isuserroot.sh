#!/bin/bash

# root user has euid = 0
check_user () {
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root" 1>&2
		exit 1
	else
		echo "Running GOD mode !"
	fi
}
check_user
