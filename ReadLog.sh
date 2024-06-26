#!/bin/bash
echo "

    ██████╗ ██████╗     ██╗      ██████╗  ██████╗ 
    ██╔══██╗██╔══██╗    ██║     ██╔═══██╗██╔════╝ 
    ██████╔╝██║  ██║    ██║     ██║   ██║██║  ███╗
    ██╔══██╗██║  ██║    ██║     ██║   ██║██║   ██║
    ██║  ██║██████╔╝    ███████╗╚██████╔╝╚██████╔╝
    ╚═╝  ╚═╝╚═════╝     ╚══════╝ ╚═════╝  ╚═════╝ 

"

echo "프로그램을 실행합니다"
sleep 1
clear

# log 파일
LOG_FILE="./NEW_LOG_FILE.log"

#파일 변경 시간 초기화
PREVIOUS_DATE=""

#로그 시작 시간 초기화, 로그에 * 가 없기에 초기 값으로 설정
LOG_TIME="\*"

# 알람 출력
alarm() {
    while true
    do 
        printf '\a'    
        sleep 0.3
    done 
}

# 소리 알람 함수
sound_alarm() {
    # alarm 함수 백그라운드 실행
    alarm &

    # alarm 함수 프로세스 ID 저장
    local alarm_process_id=$! # 지역변수로 설정

    while read -s -n 1 input
    do
        if [[ $input = q ]]; then
            if [[ $alarm_process_id != "" ]]; then
                kill $alarm_process_id
            fi
            clear
            break
        elif [[ $input = m ]]; then
            kill $alarm_process_id
            alarm_process_id=""
            echo "알람을 종료했습니다. q를 눌러 작업을 계속할 수 있습니다."
        else
            echo "$input 은(는) 잘못된 입력입니다."
        fi
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
        #clear
        return
    fi

    #파일 변경 감지 : 시간기반
    CURRENT_DATE=$(date -r "$LOG_FILE")
    if [ "$CURRENT_DATE" != "$PREVIOUS_DATE" ]; then
        #시간 조정
        PREVIOUS_DATE=$CURRENT_DATE
        NEW_LOG=$(grep -Ev "$LOG_TIME" "$LOG_FILE")
        echo "$NEW_LOG"

        #NEW_LOG 존재 유무 확인
        if [[ -z "$NEW_LOG" ]]; then
            return
        fi

        #grep을 받을 때 echo를 이용해 변수에 있는 값들을 출력하고 거기서 grep을 할 것!!! grep 뒤에 그냥 쓰면 파일이름 이라서 문제 발생!!
        if echo "$NEW_LOG" | grep -q "DOWN"; then
            
            #critical 감지
            if echo "$NEW_LOG" | grep -q "CRITICAL"; then
                echo "CRITICAL 발생"
            fi

            echo -e "\n DOWN 발생"
            DOWN_LOG=$(echo "$NEW_LOG" | grep "DOWN")
            echo -e "\n========= DOWN LOG =========\n"
            echo -e "\n$DOWN_LOG"
            echo -e "\n============================"
            echo -e "\n알람을 종료하기 위해 q를 음속어를 위해서는 m을 누르세요"
            sound_alarm
        fi
    
        LOG_TIME+=$(echo "$NEW_LOG" | grep -oP '^\[\d+\]' | tr -d '[]' | sort -u | awk 'BEGIN{sep="|"} {printf "%s%s", sep, $0; sep=" | "} END{print ""}')
    else
        echo "변경사항 없음"
    fi
    
}

# 파일 변경 메인 실행
while true
do
    check_file_change
    sleep 2
    clear
done
