#!/bin/bash

#option
OPTIONS="f:ahk?"

FOLDER=0

KEYWORD=0

#About optioin -a
CHECK_ALL=false

OPTION_FOLDER_PATH="./OPTION"

#Instructions
usage(){
    echo '
    <options>
    -a : Detect DOWN, CRITICAL - (default : only DOWN)
    -f : file path
    -h : help
    '
}

while getopts $OPTIONS opts; do
    case $opts in
    \?)
        echo "invalid option"
        usage
        exit 1
    ;;
    a)
        echo "Detect DOWN, CRITICAL"
        CHECK_ALL=true
    ;;
    f)
        FOLDER=1
    ;;
    k)
        echo "Setting keywords"
        KEYWORD=1
    ;;
    h)
        usage
        exit 1
    ;;
    esac
done

# log file
if [[ $FOLDER = 0 ]]; then
    LOG_FILE="./NEW_LOG_FILE.log"
else
    LOG_FILE=$(grep '^LOG_PATH : \[.*\]$' "$OPTION_FOLDER_PATH" | awk -F '[][]' '{print $2}')
    if [ ! -f "$LOG_FILE" ]; then
        echo "Log file does not exist in the location, please check again"
        exit 1
    fi
fi
#Initialize file change time
PREVIOUS_DATE=""

#Initialize log start time, set to initial value because log does not have *
LOG_TIME="\*"

#Number of changes required for time cancellation logic - to avoid bottleneck
TIME_FILTER_COUNTER=0

#Alarm frequency
ALARM_REPEAT=$(grep '^ALARM_REPEAT : \[.*\]$' "$OPTION_FOLDER_PATH" | awk -F '[][]' '{print $2}')

#Time Filter Count
TIME_FILTER_COUNT=$(grep '^TIME_FILTER_COUNT : \[.*\]$' "$OPTION_FOLDER_PATH" | awk -F '[][]' '{print $2}')

#Keyword-based detection
if [[ $KEYWORD = 0 ]]; then
    WORD="\s"
else
    WORD=$(grep '^KEYWORD : \[.*\]$' "$OPTION_FOLDER_PATH" | awk -F '[][]' '{print $2}')
fi

if [ -z "$ALARM_REPEAT" ]; then
    echo "Alarm repeat variable is empty. Please check OPTION"
    exit 1
fi

#Log check frequency
RDLOG_REPEAT=$(grep '^RDLOG_REPEAT : \[.*\]$' "$OPTION_FOLDER_PATH" | awk -F '[][]' '{print $2}')

if [ -z "$RDLOG_REPEAT" ]; then
    echo "Log check frequency variable is empty, please check OPTION"
    exit 1
fi
echo "

    ██████╗ ██████╗     ██╗      ██████╗  ██████╗ 
    ██╔══██╗██╔══██╗    ██║     ██╔═══██╗██╔════╝ 
    ██████╔╝██║  ██║    ██║     ██║   ██║██║  ███╗
    ██╔══██╗██║  ██║    ██║     ██║   ██║██║   ██║
    ██║  ██║██████╔╝    ███████╗╚██████╔╝╚██████╔╝
    ╚═╝  ╚═╝╚═════╝     ╚══════╝ ╚═════╝  ╚═════╝ 

"

echo "Run script"
sleep 2
clear

# Alarm output
alarm() {
    while true
    do 
        printf '\a'
        sleep $ALARM_REPEAT
    done 
}

# Sound alarm function
sound_alarm() {
    # alarm function run in background
    alarm &

    # Save alarm function process ID
    local alarm_process_id=$! # Set to local variable

    while read -s -n 1 input
    do
        case "$input" in 
            c)
                if [ "$CHECK_ALL" = true ]; then
                    CHECK_ALL=false
                    echo "Detect only DOWN"
                else
                    CHECK_ALL=true
                    echo "Detect DOWN and CRITICAL"
                fi
            ;;
            h)
                echo -e "\n==========Additional Features==========\n"
                echo " c - Down and CRITICAL detect mode inversion"
                echo " k - Keyword-based detection mode inversion"
                echo " l - Check Down and CRITICAL so far"
                echo " s - Save Down and CRITICAL so far"
                echo -e "\n======================================="
            ;;
            k) 
                if [[ $KEYWORD = 1 ]]; then
                    WORD="\s"
                    echo "Detecting keyword : NO"
                    KEYWORD=0
                else
                    WORD=$(grep '^KEYWORD : \[.*\]$' "$OPTION_FOLDER_PATH" | awk -F '[][]' '{print $2}')
                    echo "Detecting keyword : YES"
                    KEYWORD=1
                fi
            ;;
            l)
                gnome-terminal --tab -- bash -c "cat $LOG_FILE | grep -E 'DOWN|CRITICAL'; exec bash"
            ;;
            s)
                DATE_TIME=$(date +"%Y%m%d_%H%M%S")
                grep -E "DOWN|CRITICAL" mlat.log > SAVE_$DATE_TIME.txt
                echo "File saved to SAVE_$DATE_TIME.txt"
            ;;
            q)
                if [[ $alarm_process_id != "" ]]; then
                    kill $alarm_process_id
                fi
                clear
                break
            ;;
            m)
                kill $alarm_process_id
                alarm_process_id=""
                echo -e "\nYou have ended the alarm. You can continue the operation by pressing q."
            ;;
            *)
                echo "$input is an invalid input."
            ;;
        esac
    done
}

# File Change Confirmation Function
check_file_change(){
    # File Existence
    if [ ! -f "$LOG_FILE" ]; then
        echo "There are no Log file."
        echo "Run it again in a second."
        sleep 1
        clear
        return

    fi

    if [[ ! -s "$LOG_FILE" ]]; then
        echo "File is empty."
        sleep 1
        clear
        return
    fi

    #File Change Detection: Time-Based
    CURRENT_DATE=$(date -r "$LOG_FILE")
    DATE=$(date +'%Y-%m-%d')
    TIME=$(date +'%H:%M:%S')
    if [[ $CHECK_ALL = true ]]; then
        echo "Detecting DOWN and CRITICAL"
    else
        echo "Detecting DOWN only"
    fi
    if [[ $KEYWORD = 1 ]]; then
        echo "Keywords : $WORD"
    fi
    echo "Current Date: $DATE"
    echo "Current Time: $TIME"
    if [ "$CURRENT_DATE" != "$PREVIOUS_DATE" ]; then
        echo "Detection of log changes"
        TIME_FILTER_COUNTER=$((TIME_FILTER_COUNTER + 1))
        #time control
        PREVIOUS_DATE=$CURRENT_DATE
        NEW_LOG=$(grep -Ev "$LOG_TIME" "$LOG_FILE" | grep -E $WORD )

        #Check NEW_LOG exist
        if [[ -z "$NEW_LOG" ]]; then
            return
        fi

        if [ $CHECK_ALL = true ]; then
            #check all
            if echo "$NEW_LOG" | grep -qE "CRITICAL|DOWN"; then
                if echo "$NEW_LOG" | grep -q "CRITICAL"; then
                    echo -e "\n CRITICAL detected"
                fi
                if echo "$NEW_LOG" | grep -q "DOWN"; then
                    echo -e "\n DOWN detected"
                fi
                ALL_LOG=$(echo "$NEW_LOG" | grep -E "DOWN|CRITICAL")
                echo -e "\n========= DOWN LOG =========\n"
                echo -e "\n$ALL_LOG"
                echo -e "\n============================"
                echo -e "\n h - Additional Features\n q - End alarm \n m - mute"
                echo -e "============================"
                sound_alarm
            else
                echo "No DOWN and CRITICAL"
            fi
        else
           #When you get grep, use echo to print out the values in the variables and do grep from there!!! If you just write after grep, it's a file name, so there's a problem!!
            if echo "$NEW_LOG" | grep -q "DOWN"; then
                echo -e "\n DOWN detected"
                DOWN_LOG=$(echo "$NEW_LOG" | grep "DOWN")
                echo -e "\n========= DOWN LOG =========\n"
                echo -e "\n$DOWN_LOG"
                echo -e "\n============================"
                echo -e "\n h - Additional Features\n q - End alarm \n m - mute\n"
                echo -e "============================"
                sound_alarm
            else
                echo "No DOWN"
            fi
        fi

        #Logic to exclude the past time
        LOG_TIME+=$(echo "$NEW_LOG" | grep -oP '^\[\d+\]' | tr -d '[]' | sort -u | awk 'BEGIN{sep="|"} {printf "%s%s", sep, $0; sep="|"} END{print ""}')

        #Time filter - can be changed in OPTION if necessary, set to -ge, not = just in case
        if [ $TIME_FILTER_COUNTER -ge $TIME_FILTER_COUNT ]; then
            echo "Log Time Filter Operated : $TIME_FILTER_COUNTER"
            TIME_FILTER_COUNTER=0
            EXIST_IN_LOG_TIME=$(head -n 1 "$LOG_FILE" | grep -oP '^\[\d+\]' | tr -d '[]')
            FILTERED_LOG=$(echo "$LOG_TIME" | tr '|' '\n' | awk -v filter="$EXIST_IN_LOG_TIME" '$1 >= filter' | tr '\n' '|' | sed 's/|$//' | sed 's/ $//')
            LOG_TIME=$FILTERED_LOG  
        fi
    else
        echo "No log changes"
    fi
}

while true
do
    check_file_change
    sleep $RDLOG_REPEAT
    clear
done
