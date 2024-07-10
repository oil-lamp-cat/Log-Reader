#!/bin/bash

#option
OPTIONS="f:ahk?"

FOLDER=0

KEYWORD=0

#About optioin -a
CHECK_ALL=false

OPTION_FILE="./OPTION"

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

#Initialize file change time
PREVIOUS_DATE=""

#Initialize log start time, set to initial value because log does not have *
LOG_TIME="\*"

#Number of changes required for time cancellation logic - to avoid bottleneck
TIME_FILTER_COUNTER=0

#Alarm frequency
ALARM_REPEAT=$(grep '^ALARM_REPEAT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

#alarm file settings
ALARM_FILE=$(grep '^ALARM_FILE : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

#Whether to use alarm files
ALARM_FILE_ON_OFF=$(grep '^ALARM_FILE_ON_OFF : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

#Time Filter Count
TIME_FILTER_COUNT=$(grep '^TIME_FILTER_COUNT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

# log file
if [[ $FOLDER = 0 ]]; then
    LOG_FILE="./NEW_LOG_FILE.log"
else
    LOG_FILE=$(grep '^LOG_PATH : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    if [ ! -f "$LOG_FILE" ]; then
        echo "Log file does not exist in the location, please check again"
        exit 1
    else
        #Logic to import only new logs if log files already exist
        LOG_TIME+=$(cat $LOG_FILE | grep -oP '^\[\d+\]' | tr -d '[]' | sort -u | awk 'BEGIN{sep="|"} {printf "%s%s", sep, $0; sep="|"} END{print ""}')
        echo "$LOG_TIME"
        sleep 1
    fi
fi

#Keyword-based detection
if [[ $KEYWORD = 0 ]]; then
    WORD="\s"
else
    WORD=$(grep '^KEYWORD : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
fi

if [ -z "$ALARM_REPEAT" ]; then
    echo "Alarm repetition variable is empty. Please check OPTION"
    exit 1
fi

#Log Check Frequency
RDLOG_REPEAT=$(grep '^RDLOG_REPEAT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

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
    if [ "$ALARM_FILE_ON_OFF" = "ON" ]; then
        while true
            do 
                aplay $ALARM_FILE
        done >/dev/null 2>&1
    else
        while true
            do 
                printf '\a'
                sleep $ALARM_REPEAT
        done 
    fi
}

time_limit_check(){
#Run Time Limits
    ALARM_RUNNING_TIME=$(grep '^ALARM_RUNNING_TIME : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

    if [ -n "$ALARM_RUNNING_TIME" ]; then
        RUNNING_START_TIME=$(echo $ALARM_RUNNING_TIME | cut -d'-' -f1 | sed 's/://')
        RUNNING_END_TIME=$(echo $ALARM_RUNNING_TIME | cut -d'-' -f2 | sed 's/://')
    
    fi

    #Stop Time Limits
    NO_ALARM_RUNNING_TIME=$(grep '^NO_ALARM_RUNNING_TIME : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

    if [ -n "$NO_ALARM_RUNNING_TIME" ]; then
        NO_RUNNING_START_TIME=$(echo $NO_ALARM_RUNNING_TIME | cut -d'-' -f1 | sed 's/://')
        NO_RUNNING_END_TIME=$(echo $NO_ALARM_RUNNING_TIME | cut -d'-' -f2 | sed 's/://')
    fi

    #Current time
    CURRENT_TIME=$(date +%H%M)

    if [ -n "$ALARM_RUNNING_TIME" ] && [ -n "$NO_ALARM_RUNNING_TIME" ]; then
        if [ "$CURRENT_TIME" -ge "$RUNNING_START_TIME" ] && [ "$CURRENT_TIME" -le "$RUNNING_END_TIME" ] && 
           ! ([ "$CURRENT_TIME" -ge "$NO_RUNNING_START_TIME" ] && [ "$CURRENT_TIME" -le "$NO_RUNNING_END_TIME" ]); then
            return 1
        else
            echo "The alarm is off at the current time"
            return 0
        fi

    # ALARM_RUNNING_TIME만 존재하는 경우
    elif [ -n "$ALARM_RUNNING_TIME" ]; then
        if [ "$CURRENT_TIME" -ge "$RUNNING_START_TIME" ] && [ "$CURRENT_TIME" -le "$RUNNING_END_TIME" ]; then
            return 1
        else
            echo "The alarm is off at the current time"
            return 0
        fi

    # If NO_ALARM_RUNNING_TIME only exists
    elif [ -n "$NO_ALARM_RUNNING_TIME" ]; then
        if ! ([ "$CURRENT_TIME" -ge "$NO_RUNNING_START_TIME" ] && [ "$CURRENT_TIME" -le "$NO_RUNNING_END_TIME" ]); then
            return 1
        else
            echo "The alarm is off at the current time"
            return 0
        fi

    # If both ALARM_RUNNING_TIME and NO_ALARM_RUNNING_TIME are missing
    else
        return 1
    fi
}

# Sound alarm function
sound_alarm() {
    
    #Whether to run alarm
    time_limit_check
    limit=$?

    if [ "$limit" -eq 1 ]; then
        echo -e "\n h - Additional Features\n q - End alarm \n m - mute\n"
        echo -e "============================"
        # alarm run function background
        alarm &
        # Save alarm function process ID
        local alarm_process_id=""
        alarm_process_id=$!
    else
        echo -e "\n h - Additional Features\n q - End alarm \n m - It's not the alarm run time\n"
        echo -e "============================"
    fi

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
                echo " c - Down and CRITICAL detection mode inversion"
                echo " k - Keyword-based detection mode inversion"
                echo " l - Check Down and CRITICAL so far"
                echo " o - Change sound ON/OFF"
                echo " s - Save Down and CRITICAL so far"
                echo -e "\n============================"
            ;;
            k) 
                if [[ $KEYWORD = 1 ]]; then
                    WORD="\s"
                    echo "Keyword Detection : NO"
                    KEYWORD=0
                else
                    WORD=$(grep '^KEYWORD : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
                    echo "Keyword Detection : YES"
                    KEYWORD=1
                fi
            ;;
            l)
                gnome-terminal --tab -- bash -c "cat $LOG_FILE | grep -E 'DOWN|CRITICAL'; exec bash"
            ;;
            o)
                if [ "$ALARM_FILE_ON_OFF" = "ON" ]; then
                        ALARM_FILE_ON_OFF="OFF"
                        echo "Make a beep sound"
                else
                    ALARM_FILE_ON_OFF="ON"
                    echo "Make sound with ALARM file"
                fi
            ;;
            s)
                DATE_TIME=$(date +"%Y%m%d_%H%M%S")
                grep -E "DOWN|CRITICAL" mlat.log > SAVE_$DATE_TIME.txt
                echo "File saved to ./SAVE_$DATE_TIME.txt"
            ;;
            q)
                if [[ $alarm_process_id != "" ]]; then
                    kill $alarm_process_id
                fi
                clear
                break
            ;;
            m)
                if [[ $alarm_process_id != "" ]]; then
                    kill $alarm_process_id
                    echo -e "\nYou have ended the alarm. You can continue the operation by pressing q."
                else
                    echo -e "\nIt is already muted. You can press q to continue the operation."
                fi
                alarm_process_id=""
                
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
        echo "Log file not found."
        echo "Run again after 1 second."
        sleep 1
        clear
        return

    fi

    if [[ ! -s "$LOG_FILE" ]]; then
        echo "The file is empty."
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
        echo "Only detecting DOWN"
    fi
    if [[ $KEYWORD = 1 ]]; then
        echo "Keywords currently set : $WORD"
    fi
    echo "Current Date: $DATE"
    echo "Current time: $TIME"
    if [ "$CURRENT_DATE" != "$PREVIOUS_DATE" ]; then
        echo "Detection of log changes"
        TIME_FILTER_COUNTER=$((TIME_FILTER_COUNTER + 1))
        #Adjustment of time
        PREVIOUS_DATE=$CURRENT_DATE
        NEW_LOG=$(grep -Ev "$LOG_TIME" "$LOG_FILE" | grep -E $WORD )

        #Check the presence or absence of NEW_LOG
        if [[ -z "$NEW_LOG" ]]; then
            return
        fi

        if [ $CHECK_ALL = true ]; then
            #Detect all
            if echo "$NEW_LOG" | grep -qE "CRITICAL|DOWN"; then
                if echo "$NEW_LOG" | grep -q "CRITICAL"; then
                    echo -e "\n CRITICAL detected!"
                fi
                if echo "$NEW_LOG" | grep -q "DOWN"; then
                    echo -e "\n DOWN detected!"
                fi
                ALL_LOG=$(echo "$NEW_LOG" | grep -E "DOWN|CRITICAL")
                echo -e "\n========= DOWN LOG =========\n"
                echo -e "\n$ALL_LOG"
                echo -e "\n============================"
                sound_alarm
            else
                echo "No DOWN and CRITICAL"
            fi
        else
            #When you get grep, use echo to print out the values in the variables and do grep from there!!!
            #If you just write after grep, it's a file name, so there's a problem!!
            if echo "$NEW_LOG" | grep -q "DOWN"; then
                echo -e "\n DOWN detected!"
                DOWN_LOG=$(echo "$NEW_LOG" | grep "DOWN")
                echo -e "\n========= DOWN LOG =========\n"
                echo -e "\n$DOWN_LOG"
                echo -e "\n============================"
                sound_alarm
            else
                echo "NO DOWN"
            fi
        fi

        #Logic to exclude the past time
        LOG_TIME+=$(echo "$NEW_LOG" | grep -oP '^\[\d+\]' | tr -d '[]' | sort -u | awk 'BEGIN{sep="|"} {printf "%s%s", sep, $0; sep="|"} END{print ""}')

        #Time filter - can be changed in OPTION if necessary, set to -ge, not = just in case
        if [ $TIME_FILTER_COUNTER -ge $TIME_FILTER_COUNT ]; then
            echo "Log Time Filter Operated : $TIME_FILTER_COUNTER"
            #Reset back to 0 when running
            TIME_FILTER_COUNTER=0
            EXIST_IN_LOG_TIME=$(head -n 1 "$LOG_FILE" | grep -oP '^\[\d+\]' | tr -d '[]')
            FILTERED_LOG=$(echo "$LOG_TIME" | tr '|' '\n' | awk -v filter="$EXIST_IN_LOG_TIME" '$1 >= filter' | tr '\n' '|' | sed 's/|$//' | sed 's/ $//')
            LOG_TIME=$FILTERED_LOG  
        fi
    else
        echo "No log changes"
    fi
}

# File Change Main Run
while true
do
    check_file_change
    sleep $RDLOG_REPEAT
    clear
    

done
