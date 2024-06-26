#!/bin/bash

LOG_FILE="./mlat.log"

NEW_LOG_FILE="./test.log"

if [ -f "$NEW_LOG_FILE" ]; then
	rm "$NEW_LOG_FILE"
    fi

while read -r line
do
    echo "$line" >> "$NEW_LOG_FILE"
	echo "$line"
	sleep 0.2

done < "$LOG_FILE"