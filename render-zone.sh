#!/bin/bash

if (( $# < 6 )); then
    echo -e "Use:\n    ./render-zone.sh min-zoom max-zoom min-x max-X min-y max-Y\n    ex: ./render-zone.sh 11 18 459 461 909 912"
    echo -e "\n * Get tile coortonates from: http://tools.geofabrik.de/map/"
    echo " * Estimate tile render size: http://tools.geofabrik.de/calc/"
else
DateStart="`date`"
minZ="$1"
maxZ="$2"
minX="$3"
maxX="$4"
minY="$5"
maxY="$6"

if (($maxZ > 18 || $maxZ < $minZ || $minZ < 0 )); then
    echo -e "ERROR: min-zoom="$1" max-zoom="$2"\nNOTE: max-zoom <= 18 && > min-zoom"
    exit 1
fi
# Left corner x*2 y*2
# Right corner X*2+1 Y*2+1
for ((i=$minZ; i<=$maxZ; i++))
do
    echo "Zoom level $i: x$minX X$maxX y$minY Y$maxY"
    render_list -a -n4 --socket=/var/run/renderd/renderd.sock -z$i -Z$i -x$minX -X$maxX -y$minY -Y$maxY

    minX=$(($minX*2))
    maxX=$(($maxX*2+1))
    minY=$(($minY*2))
    maxY=$(($maxY*2+1))
done
echo "START: $DateStart | END: `date`"
fi
