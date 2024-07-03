#!/bin/bash

#path for test file (you could change if want)
OPTION_FOLDER_PATH="./OPTION"
LOG_FILE=$(grep '^TEST_LOG_FILE : \[.*\]$' "$OPTION_FOLDER_PATH" | awk -F '[][]' '{print $2}')
if [ -z "$LOG_FILE" ]; then
    echo "Test log file variable is empty, please check OPTION"
    exit 1
fi
if [ ! -f "$LOG_FILE" ]; then
    echo "No test log file exists in the location, please check again"
    exit 1
fi

#Files to be created for testing (no reason to change)
NEW_LOG_FILE="NEW_LOG_FILE.log"

# Simplified file presence verification
> "$NEW_LOG_FILE"

#Previous Time Storage Variables
PREV_TIME=""

#Array for store lines
LINE_ARRAY=""

while read -r line; do

	# Only the first [] was imported from grep through ^, delete [] with tr and save only the time portion
    TIME_STAMP=$(echo "$line" | grep -oP '^\[\d+\]' | tr -d '[]')

    if [[ -z "$TIME_STAMP" ]]; then
        continue
    fi

	#unix time to normal time
    CURRENT_TIME=$(date -d "@$TIME_STAMP" "+%Y-%m-%d %H:%M:%S")



    #Add a new log after changing time
    if [[ -n "$PREV_TIME" && "$PREV_TIME" != "$CURRENT_TIME" ]]; then
        echo "============================="
        echo "Previous time : $PREV_TIME"
        echo "Current time : $CURRENT_TIME"
        echo "============================="
        echo "Time change detected"
        echo -e "$LINE_ARRAY" >> "$NEW_LOG_FILE"
        #Array Initialization
        LINE_ARRAY=""
        #test sleep time
        sleep 5 #$(( $PREV_TIME - $CURRENT_TIME +%S )) #It works like a real thing with this script
		clear
    fi

    #Adding array
    if [[ -n "$LINE_ARRAY" ]]; then
        LINE_ARRAY+="\n$line"
    else
        LINE_ARRAY="$line"
    fi

    #echo "$line" >> "$NEW_LOG_FILE"
    PREV_TIME="$CURRENT_TIME"
done < "$LOG_FILE"

echo "All test log is done"