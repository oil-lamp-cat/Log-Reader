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

LOG_FILE="./test.log"

PREVIOUS_CONTENT=""

PREVIOUS_DOWN=0

CURRENT_DOWN=0

#파일 변경 확인 함수
check_file_change() {
	if [ -f "$LOG_FILE" ]; then

		#LOG_FILE 변수에 저장
		CURRENT_CONTENT=$(< "$LOG_FILE")

		#변경 감지 : 시간을 기반으로 
		if [ "$CURRENT_CONTENT" != "$PREVIOUS_CONTENT" ]; then

			#UP 수 확인
			echo "UP 수 : `cat $LOG_FILE | grep -c "UP"`"

			#DOWN 수 확인
			CURRENT_DOWN=$(grep -c "DOWN" "$LOG_FILE")
			echo "DOWN 수 : $CURRENT_DOWN"

			#CRITICAL 이 존재할 때
			if grep -q "CRITICAL" "$LOG_FILE"; then
				echo "CRITICAL 수 : `cat $LOG_FILE | grep -c "CRITICAL"`"
			fi

			#DOWN수가 변경되었을 때 소리내기
			if [ $CURRENT_DOWN -gt $PREVIOUS_DOWN ]; then
				echo -e '\a'
			fi

			PREVIOUS_DOWN=$CURRENT_DOWN
			PREVIOUS_CONTENT=$CURRENT_CONTENT
		fi
	else
		echo "로그 파일이 없습니다"
		echo "1초 뒤 다시 실행합니다"
		sleep 1
		clear
		
	fi
}



while true
do
	check_file_change
	sleep 0.2
	clear
done

