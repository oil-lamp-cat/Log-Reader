#!/bin/bash

#옵션
OPTIONS="f:ahk?"

FOLDER=0

KEYWORD=0

#옵션 관련 -a
CHECK_ALL=false

OPTION_FILE="./OPTION"

#사용법
usage(){
    echo '
    <options>
    -a : DOWN, CRITICAL감지 - (default : DOWN만 감지)
    -f : 폴더 위치
    -h : 도움말
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
        echo "모든 DOWN, CRITICAL 감지"
        CHECK_ALL=true
    ;;
    f)
        FOLDER=1
    ;;
    k)
        echo "키워드 설정"
        KEYWORD=1
    ;;
    h)
        usage
        exit 1
    ;;
    esac
done

#파일 변경 시간 초기화
PREVIOUS_DATE=""

#로그 시작 시간 초기화, 로그에 * 가 없기에 초기 값으로 설정
LOG_TIME="\*"

#시간 제거 로직에 필요한 변경사항에 따른 횟수 - 과부화 방지용
TIME_FILTER_COUNTER=0

#알람 빈도
ALARM_REPEAT=$(grep '^ALARM_REPEAT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

#알람 파일 설정
ALARM_FILE=$(grep '^ALARM_FILE : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

#알람 파일 사용 여부
ALARM_FILE_ON_OFF=$(grep '^ALARM_FILE_ON_OFF : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

#시간 필터 카운트
TIME_FILTER_COUNT=$(grep '^TIME_FILTER_COUNT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

# log 파일
if [[ $FOLDER = 0 ]]; then
    LOG_FILE="./NEW_LOG_FILE.log"
else
    LOG_FILE=$(grep '^LOG_PATH : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
    if [ ! -f "$LOG_FILE" ]; then
        echo "위치에 로그파일이 존재하지 않습니다, 다시 한번 확인해 주세요"
        exit 1
    else
        #만약 로그 파일이 이미 존재한다면 새로운 로그만 가져오기 위한 로직
        LOG_TIME+=$(cat $LOG_FILE | grep -oP '^\[\d+\]' | tr -d '[]' | sort -u | awk 'BEGIN{sep="|"} {printf "%s%s", sep, $0; sep="|"} END{print ""}')
        echo "$LOG_TIME"
        sleep 1
    fi
fi

#키워드 기반 감지
if [[ $KEYWORD = 0 ]]; then
    WORD="\s"
else
    WORD=$(grep '^KEYWORD : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
fi

if [ -z "$ALARM_REPEAT" ]; then
    echo "알람 반복 변수가 비어있습니다. OPTION을 확인해주세요"
    exit 1
fi

#로그 확인 빈도
RDLOG_REPEAT=$(grep '^RDLOG_REPEAT : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

if [ -z "$RDLOG_REPEAT" ]; then
    echo "로그 확인 빈도 변수가 비어있습니다. OPTION을 확인해주세요"
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

echo "프로그램을 실행합니다"
sleep 2
clear

# 알람 출력
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
#실행 시간 제한
    ALARM_RUNNING_TIME=$(grep '^ALARM_RUNNING_TIME : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

    if [ -n "$ALARM_RUNNING_TIME" ]; then
        RUNNING_START_TIME=$(echo $ALARM_RUNNING_TIME | cut -d'-' -f1 | sed 's/://')
        RUNNING_END_TIME=$(echo $ALARM_RUNNING_TIME | cut -d'-' -f2 | sed 's/://')
    
    fi

    #정지 시간 제한
    NO_ALARM_RUNNING_TIME=$(grep '^NO_ALARM_RUNNING_TIME : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')

    if [ -n "$NO_ALARM_RUNNING_TIME" ]; then
        NO_RUNNING_START_TIME=$(echo $NO_ALARM_RUNNING_TIME | cut -d'-' -f1 | sed 's/://')
        NO_RUNNING_END_TIME=$(echo $NO_ALARM_RUNNING_TIME | cut -d'-' -f2 | sed 's/://')
    fi

    #현재 시간
    CURRENT_TIME=$(date +%H%M)

    if [ -n "$ALARM_RUNNING_TIME" ] && [ -n "$NO_ALARM_RUNNING_TIME" ]; then
        if [ "$CURRENT_TIME" -ge "$RUNNING_START_TIME" ] && [ "$CURRENT_TIME" -le "$RUNNING_END_TIME" ] && 
           ! ([ "$CURRENT_TIME" -ge "$NO_RUNNING_START_TIME" ] && [ "$CURRENT_TIME" -le "$NO_RUNNING_END_TIME" ]); then
            return 1
        else
            echo "현재 시간은 알람이 종료되어있습니다"
            return 0
        fi

    # ALARM_RUNNING_TIME만 존재하는 경우
    elif [ -n "$ALARM_RUNNING_TIME" ]; then
        if [ "$CURRENT_TIME" -ge "$RUNNING_START_TIME" ] && [ "$CURRENT_TIME" -le "$RUNNING_END_TIME" ]; then
            return 1
        else
            echo "현재 시간은 알람이 종료되어있습니다"
            return 0
        fi

    # NO_ALARM_RUNNING_TIME만 존재하는 경우
    elif [ -n "$NO_ALARM_RUNNING_TIME" ]; then
        if ! ([ "$CURRENT_TIME" -ge "$NO_RUNNING_START_TIME" ] && [ "$CURRENT_TIME" -le "$NO_RUNNING_END_TIME" ]); then
            return 1
        else
            echo "현재 시간은 알람이 종료되어있습니다"
            return 0
        fi

    # ALARM_RUNNING_TIME과 NO_ALARM_RUNNING_TIME이 모두 없는 경우
    else
        return 1
    fi
}

# 소리 알람 함수
sound_alarm() {
    
    #alarm 실행할지 여부
    time_limit_check
    limit=$?

    if [ "$limit" -eq 1 ]; then
        echo -e "\n h - 추가기능\n q - 알람 종료 \n m - 음속어\n"
        echo -e "============================"
        # alarm 함수 백그라운드 실행
        alarm &
        # alarm 함수 프로세스 ID 저장
        local alarm_process_id=""
        alarm_process_id=$! # 지역변수로 설정
    else
        echo -e "\n h - 추가기능\n q - 알람 종료 \n m - 알람 실행 시간이 아닙니다\n"
        echo -e "============================"
    fi

    while read -s -n 1 input
    do
        case "$input" in 
            c)
                if [ "$CHECK_ALL" = true ]; then
                    CHECK_ALL=false
                    echo "DOWN만 감지합니다"
                else
                    CHECK_ALL=true
                    echo "DOWN과 CRITICAL을 감지합니다"
                fi
            ;;
            h)
                echo -e "\n==========추가기능==========\n"
                echo " c - DOWN과 CRITICAL감지 모드 반전"
                echo " k - 키워드 기반 감지 모드 반전"
                echo " l - 지금까지의 DOWN과 CRITICAL 확인"
                echo " o - 소리 ON/OFF 변경"
                echo " s - 지금까지의 DOWN과 CRITICAL 저장"
                echo -e "\n============================"
            ;;
            k) 
                if [[ $KEYWORD = 1 ]]; then
                    WORD="\s"
                    echo "키워드 감지 NO"
                    KEYWORD=0
                else
                    WORD=$(grep '^KEYWORD : \[.*\]$' "$OPTION_FILE" | awk -F '[][]' '{print $2}')
                    echo "키워드 감지 YES"
                    KEYWORD=1
                fi
            ;;
            l)
                gnome-terminal --tab -- bash -c "cat $LOG_FILE | grep -E 'DOWN|CRITICAL'; exec bash"
            ;;
            o)
                if [ "$ALARM_FILE_ON_OFF" = "ON" ]; then
                        ALARM_FILE_ON_OFF="OFF"
                        echo "비프음으로 소리를 냅니다"
                else
                    ALARM_FILE_ON_OFF="ON"
                    echo "ALARM 파일으로 소리를 냅니다"
                fi
            ;;
            s)
                DATE_TIME=$(date +"%Y%m%d_%H%M%S")
                grep -E "DOWN|CRITICAL" mlat.log > SAVE_$DATE_TIME.txt
                echo "SAVE_$DATE_TIME.txt 파일에 저장하였습니다"
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
                    echo -e "\n알람을 종료했습니다. q를 눌러 작업을 계속할 수 있습니다."
                else
                    echo -e "\n이미 mute되어있습니다. q를 눌러 작업을 계속할 수 있습니다."
                fi
                alarm_process_id=""
                
            ;;
            *)
                echo "$input 은(는) 잘못된 입력입니다."
            ;;
        esac
    done
}

# 파일 변경 확인 함수
check_file_change(){
    # 파일 존재 유무
    if [ ! -f "$LOG_FILE" ]; then
        echo "로그 파일이 없습니다."
        echo "1초 뒤 다시 실행합니다."
        sleep 1
        clear
        return

    fi

    if [[ ! -s "$LOG_FILE" ]]; then
        echo "파일이 비어있습니다."
        sleep 1
        clear
        return
    fi

    #파일 변경 감지 : 시간기반
    CURRENT_DATE=$(date -r "$LOG_FILE")
    DATE=$(date +'%Y-%m-%d')
    TIME=$(date +'%H:%M:%S')
    if [[ $CHECK_ALL = true ]]; then
        echo "DOWN과 CRITICAL을 감지중입니다"
    else
        echo "DOWN만 감지중입니다"
    fi
    if [[ $KEYWORD = 1 ]]; then
        echo "현재 설정된 키워드 : $WORD"
    fi
    echo "현재 날짜: $DATE"
    echo "현재 시간: $TIME"
    if [ "$CURRENT_DATE" != "$PREVIOUS_DATE" ]; then
        echo "로그 변경사항 감지"
        TIME_FILTER_COUNTER=$((TIME_FILTER_COUNTER + 1))
        #시간 조정
        PREVIOUS_DATE=$CURRENT_DATE
        NEW_LOG=$(grep -Ev "$LOG_TIME" "$LOG_FILE" | grep -E $WORD )

        #NEW_LOG 존재 유무 확인
        if [[ -z "$NEW_LOG" ]]; then
            return
        fi

        if [ $CHECK_ALL = true ]; then
            #전체 감지
            if echo "$NEW_LOG" | grep -qE "CRITICAL|DOWN"; then
                if echo "$NEW_LOG" | grep -q "CRITICAL"; then
                    echo -e "\n CRITICAL 발생"
                fi
                if echo "$NEW_LOG" | grep -q "DOWN"; then
                    echo -e "\n DOWN 발생"
                fi
                ALL_LOG=$(echo "$NEW_LOG" | grep -E "DOWN|CRITICAL")
                echo -e "\n========= DOWN LOG =========\n"
                echo -e "\n$ALL_LOG"
                echo -e "\n============================"
                sound_alarm
            else
                echo "DOWN및 CRITICAL 없음"
            fi
        else
            #grep을 받을 때 echo를 이용해 변수에 있는 값들을 출력하고 거기서 grep을 할 것!!! grep 뒤에 그냥 쓰면 파일 이름 이라서 문제 발생!!
            if echo "$NEW_LOG" | grep -q "DOWN"; then
                echo -e "\n DOWN 발생"
                DOWN_LOG=$(echo "$NEW_LOG" | grep "DOWN")
                echo -e "\n========= DOWN LOG =========\n"
                echo -e "\n$DOWN_LOG"
                echo -e "\n============================"
                sound_alarm
            else
                echo "DOWN 없음"
            fi
        fi

        #이미 지난 시간 제외하기 위한 로직
        LOG_TIME+=$(echo "$NEW_LOG" | grep -oP '^\[\d+\]' | tr -d '[]' | sort -u | awk 'BEGIN{sep="|"} {printf "%s%s", sep, $0; sep="|"} END{print ""}')

        #시간 필터 - 필요시 OPTION에서 변경 가능, 혹시 몰라서 =이 아니라 -ge로 설정
        if [ $TIME_FILTER_COUNTER -ge $TIME_FILTER_COUNT ]; then
            echo "로그 시간 필터 작동됨 : $TIME_FILTER_COUNTER"
            #실행 되면 다시 0으로 리셋
            TIME_FILTER_COUNTER=0
            EXIST_IN_LOG_TIME=$(head -n 1 "$LOG_FILE" | grep -oP '^\[\d+\]' | tr -d '[]')
            FILTERED_LOG=$(echo "$LOG_TIME" | tr '|' '\n' | awk -v filter="$EXIST_IN_LOG_TIME" '$1 >= filter' | tr '\n' '|' | sed 's/|$//' | sed 's/ $//')
            LOG_TIME=$FILTERED_LOG  
        fi
    else
        echo "로그 변경사항 없음"
    fi
}

# 파일 변경 메인 실행
while true
do
    check_file_change
    sleep $RDLOG_REPEAT
    clear
    

done
