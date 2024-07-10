#!/bin/bash

OPTION_FILE="./OPTION"
OPTIONS=":th?"
OPTION_TRUE=0
USER_ID=$USER
HOST_NAME=$(hostname)

usage()
{
    echo '
    <options>
    -t : run test script
    -f : f [folder path]
    -k : use keyword
    -h : help
    '
}

test_s(){
    gnome-terminal --tab -- bash -c "./MKlog.sh; exec bash"

    gnome-terminal --tab -- bash -c "./ReadLog.sh; exec bash"
}

read_log_d(){
    gnome-terminal -- bash -c "./ReadLog.sh -f $OPTION_FILE; exec bash"

}

read_log_a(){
    gnome-terminal -- bash -c "./ReadLog.sh -a -f $OPTION_FILE; exec bash"
}

keyword_read_log(){
    gnome-terminal -- bash -c "./ReadLog.sh -a -k -f $OPTION_FILE; exec bash"
}

change(){
        local OPTION_TYPE="$1"
        local CHANGE_TO="$2"
        local PREVIOUS="$3"
        echo "Will you change $PREVIOUS  to $CHANGE_TO in $OPTION_TYPE OPTION? Y/N"
        printf "$USER_ID@$HOST_NAME> "
        read yn
        if [ "$OPTION_TYPE" = "LOG_PATH" ] || [ "$OPTION_TYPE" = "TEST_LOG_FILE" ] || [ "$OPTION_TYPE" = "ALARM_FILE" ]; then
            if ! [ -f "$CHANGE_TO" ]; then
                option_setting "File doesn't exist."
                return
            fi
        fi
        if [ "$OPTION_TYPE" = "ALARM_FILE_ON_OFF" ]; then
            if [ "$CHANGE_TO" != "ON" ] && [ "$CHANGE_TO" != "OFF" ]; then
                option_setting "ALARM_FILE_ON_OFF option only able to use ON or OFF."
                return
            fi
        fi
        case "$yn" in
        [yY])
            sed -i "s/^\($OPTION_TYPE : \[\)[^]]*\(\]\)/\1$(echo "$CHANGE_TO" | sed -e 's/[\/&]/\\&/g')\2/" "$OPTION_FILE"
            option_setting "$PREVIOUS is changed to $CHANGE_TO in $OPTION_TYPE OPTION"
        ;;
        [nN])
            option_setting "There are no changes"
        ;;
        *)
            option_setting "$yn is invalid input"
        ;;
    esac
}

option_setting(){
    clear

    local CHANGED_LOG="${1:-NONE}"

    local LOG_FILE=$(grep '^LOG_PATH : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local ALARM_REPEAT=$(grep '^ALARM_REPEAT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local ALARM_FILE=$(grep '^ALARM_FILE : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local ALARM_FILE_ON_OFF=$(grep '^ALARM_FILE_ON_OFF : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local TEST_LOG_FILE=$(grep '^TEST_LOG_FILE : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local TIME_FILTER_COUNT=$(grep '^TIME_FILTER_COUNT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local WORD=$(grep '^KEYWORD : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local RDLOG_REPEAT=$(grep '^RDLOG_REPEAT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local ALARM_RUNNING_TIME=$(grep '^ALARM_RUNNING_TIME : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local NO_ALARM_RUNNING_TIME=$(grep '^NO_ALARM_RUNNING_TIME : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

    if [ -z "$ALARM_RUNNING_TIME" ]; then
        ALARM_RUNNING_TIME="EMPTY"
    fi

    if [ -z "$NO_ALARM_RUNNING_TIME" ]; then
        NO_ALARM_RUNNING_TIME="EMPTY"
    fi


    echo -e "\n OPTION setting"
    echo "
    # Enter the number you want to change
    # Or you can press q to go to the main

    1.LOG_PATH                | $LOG_FILE
    2.TEST_LOG_FILE           | $TEST_LOG_FILE
    3.ALARM_REPEAT            | $ALARM_REPEAT
    4.ALARM_FILE              | $ALARM_FILE
    5.ALARM_FILE_ON_OFF       | $ALARM_FILE_ON_OFF
    6.RDLOG_REPEAT            | $RDLOG_REPEAT
    7.TIME_FILTER_COUNT       | $TIME_FILTER_COUNT
    8.KEYWORD                 | $WORD
    9.ALARM_RUNNING_TIME      | $ALARM_RUNNING_TIME
    10.NO_ALARM_RUNNING_TIME  | $NO_ALARM_RUNNING_TIME
    "

    if [ "$CHANGED_LOG" != "NONE" ]; then
        echo -e "   $CHANGED_LOG \n"
    fi

    printf "$USER_ID@$HOST_NAME> "
    read task_input

    case "$task_input" in
        1)
            clear
            echo " LOG_PATH : $LOG_FILE"
            echo -e " Put the location of the log file you want to change\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "LOG_PATH" "$change" "$LOG_FILE"
        ;;
        2)
            clear
            echo " TEST_LOG_FILE : $TEST_LOG_FILE"
            echo -e " Put the location of the log file you want to change\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "TEST_LOG_FILE" "$change" "$TEST_LOG_FILE"
        ;;
        3)
            clear
            echo " ALARM_REPEAT : $ALARM_REPEAT"
            echo -e " Frequency of alarm output - Default 0.3s, Please enter numbers only\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "ALARM_REPEAT" "$change" "$ALARM_REPEAT"
        ;;
        4)
            clear
            echo " ALARM_FILE : $ALARM_FILE"
            echo " The location of the alarm file\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "ALARM_FILE" "$change" "$ALARM_FILE"            
        ;;
        5)
            clear
            echo " ALARM_FILE_ON_OFF : $ALARM_FILE_ON_OFF"
            echo " You can use alarm files, ex) ON/OFF"
            echo -e "Able to change them while running a script\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "ALARM_FILE_ON_OFF" "$change" "$ALARM_FILE_ON_OFF"   
        ;;
        6)
            clear
            echo " RDLOG_REPEAT : $RDLOG_REPEAT"
            echo -e " Log read frequency - default 2s, please enter numbers only\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "RDLOG_REPEAT" "$change" "$RDLOG_REPEAT"
        ;;
        7)
            clear
            echo " TIME_FILTER_COUNT : $TIME_FILTER_COUNT"
            echo " Time-exclude filters - default 10 times, please enter numbers only"
            echo -e "Used for Overflow Protection\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "TIME_FILTER_COUNT" "$change" "$TIME_FILTER_COUNT"
        ;;
        8)
            clear
            echo " KEYWORD : $WORD"
            echo -e " Log with keywords, type in words|word\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "KEYWORD" "$change" "$WORD"
        ;;
        9)
            clear
            echo " ALARM_RUNNING_TIME : $ALARM_RUNNING_TIME"
            echo " Run for a specific time only, ex) 08:00-18:30"
            echo "(Please type in large|small)"
            echo -e " If you leave it empty, it will run for 24 hours\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "ALARM_RUNNING_TIME" "$change" "$ALARM_RUNNING_TIME"
        ;;
        10)
            clear
            echo "NO_ALARM_RUNNING_TIME : $NO_ALARM_RUNNING_TIME"
            echo " Do not run alarms for a specific time, ex) 08:00-18:30"
            echo "(Please type in large|small)"
            echo -e " If you leave it empty, it will run for 24 hours\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "NO_ALARM_RUNNING_TIME" "$change" "$NO_ALARM_RUNNING_TIME"
        ;;
        q)
            echo "Exit the setup"
            clear
            main
        ;;
        *)
            sleep 1
            clear
            option_setting "Invalid input"
        ;;
    esac

}

cat_meow(){
    clear
    echo "
        へ 
     （• ˕ •マ  meow~
       |､  ~ヽ         
       じしf_,)〳
    "    
}

main(){


    if [ $OPTION_TRUE -eq 0 ]; then
        clear
        echo "
        start -main.sh-

        へ 
      （• ˕ •マ 
        |､  ~ヽ         
        じしf_,)〳       made by LampCat

        #All scripts can be exited by pressing ctrl+c#

        1. Run Test Script (MKlog.sh , ReadLog.sh ) - A new tab will be opened
        2. Log Read Script (ReadLog.sh ) - Only DOWN detected
        3. Log Read Script Runs in Full Detection Mode (ReadLog.sh ) - DOWN, CRITICAL Detection
        4. DETECTION OF DOWN, CRITICAL WITH SPECIFIC WORDS
        5. Option setting
        6. If there's any problem
        q. exit
        "
        printf "$USER_ID@$HOST_NAME> "
        read task_input

        case "$task_input" in
            1)
                test_s
            ;;
            2)
                read_log_d
            ;;
            3)
                read_log_a
            ;;
            4)
                keyword_read_log
            ;;
            5)
                option_setting
            ;;
            6)
                echo -e "\n ====blog===="
                echo " https://oil-lamp-cat.github.io/"
                echo -e "\n ====email===="
                echo -e " raen0730@gmail.com\n"
                exit 1
            ;;
            q)
                echo "EXIT"
                sleep 1
                clear
                exit 1
            ;;
            cat)
                cat_meow
                exit 1
            ;;
            * )
                echo "Invalid input"
                exit 1
            ;;
        esac
    fi
}

while getopts $OPTIONS opts; do
    case $opts in
    \?)
        echo "invalid option"
        usage
        exit 1;;
    t) 
        echo "Running a test script"
        test_s
        OPTION_TRUE=1
    ;;
    h)
        exit 1
    ;;
    :)
        usage
        exit 1
    ;;
    esac
done

if [ ! -f "$OPTION_FILE" ]; then
    clear
    echo "There are no 'OPTION' file."
    touch "$OPTION_FILE"
    echo "#Just put in side square bracket!
#If theres problem contact : https://oil-lamp-cat.github.io/

#Put the log path where you want to read it here
LOG_PATH : [./mlat.log]

#Frequency of alarm output - Default 0.3s
ALARM_REPEAT : [0.3]

#Alarm file - can be turned ON/OFF in OPTION settings
ALARM_FILE : [./beep_alarm.wav]
ALARM_FILE_ON_OFF : [OFF]

#The location of the log file to be used for the test log. 
#You can put the log file you want to use for the test.
TEST_LOG_FILE : [./mlat.log]

#Freqency of log reads - Default 2s, checking that files have changed every 2 seconds.
RDLOG_REPEAT : [2]

#Number of time-out filters, for example, when the default is 10, the time filter is checked once after 10 log file changes have been detected
#If there is a time deleted from the log when checked, delete all time zones from the code's FILTER_LOG variable
#When using the test script, about 10 times was appropriate, but please change it according to the frequency of log reading and the actual log generation time
#To prevent overflow
TIME_FILTER_COUNT : [10]

#Used when using option -k for log detection with specific keywords
#word|word, no space between words, for use grep -E option
#Default setting capture CWP and FUSION
KEYWORD : [CWP|FUSION]

#Set to run for a specific time only ex) H:M, [08:00-18:30]
ALARM_RUNNING_TIME : []

#Set it to not run for a certain period of time ex) H:M, [08:00-18:30]
NO_ALARM_RUNNING_TIME : []
    " > "$OPTION_FILE"
    echo "./OPTION file is created, option setting will be open"
    sleep 2
    option_setting
fi

main