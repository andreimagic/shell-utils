#!/bin/sh

# [ "$(curl -s localhost:8081 | jq -r '.alpha.status')" == "healthy" ]

if [ "$(curl -s -X GET localhost:8081 | jq -r '.alpha.status')" == "healthy" ]; then
    echo "0"
    exit 0
else
    echo "1"
    exit 1
fi