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
    -t : 테스트 스크립트 실행
    -f : 폴더 선택
    -k : 키워드 설정
    -h : 도움말
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
        echo "$OPTION_TYPE 의 $PREVIOUS 에서 $CHANGE_TO 로 변경하시겠습니까? Y/N"
        printf "$USER_ID@$HOST_NAME> "
        read yn
        if [ "$OPTION_TYPE" = "LOG_PATH" ] || [ "$OPTION_TYPE" = "TEST_LOG_FILE" ] || [ "$OPTION_TYPE" = "ALARM_FILE" ]; then
            if ! [ -f "$CHANGE_TO" ]; then
                option_setting "파일이 존재하지 않습니다."
            fi
        fi
        case "$yn" in
        [yY])
            sed -i "s/\($OPTION_TYPE : \[\)[^]]*\(\]\)/\1$(echo "$CHANGE_TO" | sed -e 's/[\/&]/\\&/g')\2/" "$OPTION_FILE"
            option_setting "$OPTION_TYPE 의 $PREVIOUS 에서 $CHANGE_TO (으)로 변경되었습니다"
        ;;
        [nN])
            option_setting "변경사항이 없습니다"
        ;;
        *)
            option_setting "$yn 은 잘못된 입력값입니다"
        ;;
    esac
}

option_setting(){
    clear

    local CHANGED_LOG="${1:-NONE}"

    local LOG_FILE=$(grep '^LOG_PATH : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local ALARM_REPEAT=$(grep '^ALARM_REPEAT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local ALARM_FILE=$(grep '^ALARM_FILE : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local ALARM_ON_OFF=$(grep '^ALARM_ON_OFF : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local TEST_LOG_FILE=$(grep '^TEST_LOG_FILE : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local TIME_FILTER_COUNT=$(grep '^TIME_FILTER_COUNT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local WORD=$(grep '^KEYWORD : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local RDLOG_REPEAT=$(grep '^RDLOG_REPEAT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local RUNNING_TIME=$(grep '^RUNNING_TIME : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    local NO_RUNNING_TIME=$(grep '^NO_RUNNING_TIME : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    echo -e "\n 옵션 설정"
    echo "
    # 변경을 하고자 하는 숫자를 입력 하거나
    # q를 눌러 다시 메인으로 가실 수 있습니다

    1.LOG_PATH : $LOG_FILE
    2.TEST_LOG_FILE : $TEST_LOG_FILE
    3.ALARM_REPEAT : $ALARM_REPEAT
    4.ALARM_FILE : $ALARM_FILE
    5.ALARM_ON_OFF : $ALARM_ON_OFF
    6.RDLOG_REPEAT : $RDLOG_REPEAT
    7.TIME_FILTER_COUNT : $TIME_FILTER_COUNT
    8.KEYWORD : $WORD
    9.RUNNING_TIME : $RUNNING_TIME
    10.NO_RUNNING_TIME : $NO_RUNNING_TIME
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
            echo -e " 변경하고 싶은 log파일의 위치를 넣으세요\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "LOG_PATH" "$change" "$LOG_FILE"
        ;;
        2)
            clear
            echo " TEST_LOG_FILE : $TEST_LOG_FILE"
            echo -e " 변경하고 싶은 log파일의 위치를 넣으세요\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "TEST_LOG_FILE" "$change" "$TEST_LOG_FILE"
        ;;
        3)
            clear
            echo " ALARM_REPEAT : $ALARM_REPEAT"
            echo -e " 알람 출력 빈도입니다 - 기본 0.3s, 입력은 숫자만 입력해주세요\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "ALARM_REPEAT" "$change" "$ALARM_REPEAT"
        ;;
        4)
            clear
            echo " ALARM_FILE : $ALARM_FILE"
            echo -e " 알람 파일입니다\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "ALARM_FILE" "$change" "$ALARM_FILE"            
        ;;
        5)
            clear
            echo " ALARM_ON_OFF : $ALARM_ON_OFF"
            echo -e " 알람 파일을 끄고 킬 수 있습니다, 스크립트 실행 중에도 안에서 변경 가능"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "ALARM_ON_OFF" "$change" "$ALARM_ON_OFF"   
        ;;
        6)
            clear
            echo " RDLOG_REPEAT : $RDLOG_REPEAT"
            echo -e " 로그 읽는 빈도수 입니다 - 기본 2s, 입력은 숫자만 입력해주세요\n"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "RDLOG_REPEAT" "$change" "$RDLOG_REPEAT"
        ;;
        7)
            clear
            echo " TIME_FILTER_COUNT : $TIME_FILTER_COUNT"
            echo -e " 시간 제외 필터 횟수입니다 - 기본 10회, 입력은 숫자만 입력해주세요"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "TIME_FILTER_COUNT" "$change" "$TIME_FILTER_COUNT"
        ;;
        8)
            clear
            echo " KEYWORD : $WORD"
            echo -e " 키워드 포함 로그 검출, 단어|단어 로 입력해 주세요"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "KEYWORD" "$change" "$WORD"
        ;;
        9)
            clear
            echo " RUNNING_TIME : $RUNNING_TIME"
            echo -e " 특정 시간 동안에만 실행, 08:00-18:30 로 입력해 주세요"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "RUNNING_TIME" "$change" "$RUNNING_TIME"
        ;;
        10)
            clear
            echo "NO_RUNNING_TIME : $NO_RUNNING_TIME"
            echo "특정 시간 동안 실행 안함, 08:00-18:30 로 입력해 주세요"
            printf "$USER_ID@$HOST_NAME> "
            read change
            change "NO_RUNNING_TIME" "$change" "$NO_RUNNING_TIME"
        ;;
        q)
            echo "설정을 종료합니다"
            clear
            main
        ;;
        *)
            sleep 1
            clear
            option_setting "잘못된 입력입니다"
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

        #모든 스크립트는 ctrl+c를 눌러 빠져나올 수 있습니다#

        1. 테스트 스크립트 실행 (MKlog.sh, ReadLog.sh) - 새로운 tab이 열릴 것입니다
        2. 로그 읽는 스크립트 실행 (ReadLog.sh) - DOWN만 감지
        3. 로그 읽는 스크립트 전체 감지 모드로 실행 (ReadLog.sh) - DOWN, CRITICAL 감지
        4. 특정 단어가 포함된 DOWN, CRITICAL 감지
        5. 옵션 설정
        6. 도움이 필요하다면 이곳으로
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
                echo "종료합니다"
                exit 1
            ;;
            cat)
                cat_meow
                exit 1
            ;;
            * )
                echo "잘못된 입력입니다"
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
        echo "테스트 스크립트 실행"
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
    echo "옵션 파일이 존재하지 않습니다."
    touch "$OPTION_FILE"
    echo "#대괄호를 삭제하지 말고 안에 넣기!
#문제 발생시 : https://oil-lamp-cat.github.io/

#이곳에 읽고자 하는 log의 위치를 넣으세요
LOG_PATH : [./mlat.log]

#알람 출력 빈도입니다 - 기본 0.3s
ALARM_REPEAT : [0.3]

#알람 파일입니다 - OPTION 설정에서 on/off 할 수 있습니다
ALARM_FILE : []
ALARM_ON_OFF : [NO]

#테스트 로그에 사용될 로그 파일 위치입니다, 테스트에 쓰고 싶은 로그 파일을 넣으시면 됩니다
TEST_LOG_FILE : [./mlat.log]

#로그 읽는 빈도수 입니다 - 기본 2s, 2초마다 파일이 변경되었는지 확인
RDLOG_REPEAT : [2]

#시간 제외 필터 횟수입니다, 예를들어 기본 10일 때에는 로그 파일 변경이 10회 감지되고 나서야 시간 필터를 한번 검사합니다
#검사시 로그에 삭제된 시간이 존재한다면 코드의 FILTER_LOG변수에서 그 시간대를 전부 삭제합니다
#테스트 스크립트를 이용하였을 때에는 10회 정도가 적당하였으나 로그 읽는 빈도수, 실제 로그 생성 시간에 맞춰 알맞게 변경하시기 바랍니다
TIME_FILTER_COUNT : [10]

#특정 키워드가 포함된 로그 검출을 위한 옵션 -k를 이용할 때 사용됨
#단어|단어 로 구성되어야함
#아래는 기본 세팅
KEYWORD : [CWP|FUSION]

#특정 시간 동안에만 실행될 수 있게 세팅 ex) H:M, [08:00-18:30]
RUNNING_TIME : []

#특정 시간 동안에는 실행되지 않게 세팅 ex) H:M, [08:00-18:30]
NO_RUNNING_TIME : []
    " > "$OPTION_FILE"
    echo "./OPTION 파일을 생성하였으니 옵션 세팅을 열겠습니다"
    sleep 2
    option_setting
fi

main