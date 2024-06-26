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

# 이전 시간 저장
PREV_TIME=0

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

    
}

# 파일 변경 메인 실행
while true
do
    check_file_change
    sleep 17
    clear
done
