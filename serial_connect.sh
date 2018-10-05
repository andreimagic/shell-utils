#!/bin/sh

# connect.sh

# Usage:
# $ connect.sh <device> <port speed>
# Example: connect.sh /dev/ttySP0 38400

# Set up device
stty -F $1 $2 cs8 echoke echoctl echok echoe iexten icanon isig opost onlcr -ignpar -cstopb -ignpar -echo -brkint -imaxbel

# Let cat read the device $1 in the background
cat $1 &

# Read commands from user, send them to device $1
while read cmd
do
   echo "$cmd"
done > $1
 