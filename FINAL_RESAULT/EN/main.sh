#!/bin/bash

OPTION_FOLDER_PATH="./OPTION"
OPTIONS=":th?"
OPTION_TRUE=0
USER_ID=$USER
HOST_NAME=$(hostname)

if [ ! -f "$OPTION_FOLDER_PATH" ]; then
    clear
    echo "There are no 'OPTION' file."
    touch "$OPTION_FOLDER_PATH"
    echo "#Just put in side square bracket!
#If theres problem contact : https://oil-lamp-cat.github.io/

#Put the log path where you want to read it here
LOG_PATH : [./mlat.log]

#Frequency of alarm output - Default 0.3s
ALARM_REPEAT : [0.3]

#The location of the log file to be used for the test log. 
#You can put the log file you want to use for the test.
TEST_LOG_FILE : [./mlat.log]

#Number of log reads - Default 2s, checking that files have changed every 2 seconds.
RDLOG_REPEAT : [2]

#Number of time-out filters, for example, when the default is 10, the time filter is checked once after 10 log file changes have been detected
#If there is a time deleted from the log when checked, delete all time zones from the code's FILTER_LOG variable
#When using the test script, about 10 times was appropriate, but please change it according to the frequency of log reading and the actual log generation time
TIME_FILTER_COUNT : [10]

#Used when using option -k for log detection with specific keywords
#word|word, no space between words, for use grep -E option
#Default setting capture CWP and FUSION
KEYWORD : [CWP|FUSION]


If you want to change mode like only detect down to detect all then you could change it while error captured with click 'h'
    " > "$OPTION_FOLDER_PATH"
    echo "./OPTION file is created, so please check options and come back after you finish setting it up"
    exit 1
fi

usage()
{
    echo '
    <options>
    -t : run test script
    -f : -f [folder path]
    -k : use keyword
    -h : help
    '
}

test_s(){
    gnome-terminal --tab -- bash -c "./MKlog.sh; exec bash"

    gnome-terminal --tab -- bash -c "./ReadLog.sh; exec bash"
}

read_log_d(){
    gnome-terminal -- bash -c "./ReadLog.sh -f $OPTION_FOLDER_PATH; exec bash"

}

read_log_a(){
    gnome-terminal -- bash -c "./ReadLog.sh -a -f $OPTION_FOLDER_PATH; exec bash"
}

keyword_read_log(){
    gnome-terminal -- bash -c "./ReadLog.sh -a -k -f $OPTION_FOLDER_PATH; exec bash"
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

while getopts $OPTIONS opts; do
    case $opts in
    \?)
        echo "Invalid option"
        usage
        exit 1;;
    t) 
        echo "Run test script"
        test_s
        OPTION_TRUE=1
    ;;
    h)
        usage
        exit 1
    ;;
    :)
        usage
        exit 1
    ;;
    esac
done

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
    5. If there's any problem -> 
    "
    printf "$USER_ID@$HOST_NAME > "
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
            echo -e "\n ====blog===="
            echo " https://oil-lamp-cat.github.io/"
            echo -e "\n ====email===="
            echo -e " raen0730@gmail.com\n"
            exit 1
        ;;
        cat)
            cat_meow
            exit 1
        ;;
        * )
            echo "wrong input, please try again"
            exit 1
        ;;
    esac
fi