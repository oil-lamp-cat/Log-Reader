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

#log 파일
LOG_FILE="./test.log"

#파일 변경 시간 초기화
PREVIOUS_DATE=""

#DOWN 수
PREVIOUS_DOWN=0

#UP 수
CURRENT_DOWN=0

#DOWN 출력 초기화
DOWN_LOG=""

#DOWN 수 초기화
DOWN_COUNT=0

# 알람 출력
alarm() {
	while true
	do 
		printf '\a'	
		sleep 0.3
	done 
}

#소리 알람 함수
sound_alarm() {

	#alarm 함수 백그라운드 실행
	alarm &

	# alarm 함수 프로세스 ID 저장
	alarm_process_id=$!

	while read -s -n 1 input
	do
		if [[ $input = q ]]; then
			if [[ $alarm_process_id !=  "" ]]; then
				kill $alarm_process_id
			fi
			break
		elif [[ $input = m ]]; then
			kill $alarm_process_id
			alarm_process_id=""
			echo "알람을 종료했습니다 q를 눌러 작업을 계속할 수 있습니다"
		else
			echo "$input 은 잘못된 입력입니다"
		fi
	done
}

#파일 변경 확인 함수
check_file_change() {
	#파일 존재 유무
	if [ -f "$LOG_FILE" ]; then

		#LOG_FILE 변경 시간을 저장
		CURRENT_DATE=$(date -r "$LOG_FILE")

		#변경 감지 : 시간을 기반으로 
		if [ "$CURRENT_DATE" != "$PREVIOUS_DATE" ]; then

			#UP 수 확인
			echo " UP 수 : `cat $LOG_FILE | grep -c "UP"`"

			#DOWN 수 확인
			CURRENT_DOWN=$(grep -c "DOWN" "$LOG_FILE")
			echo " DOWN 수 : $CURRENT_DOWN"

			#CRITICAL 이 존재할 때
			if grep -q "CRITICAL" "$LOG_FILE"; then
				echo " CRITICAL 수 : `cat $LOG_FILE | grep -c "CRITICAL"`"
			fi

			#DOWN수가 변경되었을 때 소리내기
			if [ $CURRENT_DOWN -gt $PREVIOUS_DOWN ]; then
				echo  -e "\n DOWN 발생"
				DOWN_LOG=$(grep "DOWN" "$LOG_FILE")
				DOWN_COUNT=$(($CURRENT_DOWN - $PREVIOUS_DOWN ))
				echo " $PREVIOUS_DOWN -> $CURRENT_DOWN"
				echo -e "\n========= DOWN LOG =========\n"
				echo -e "\n$DOWN_LOG" | tail -n $DOWN_COUNT
				echo -e "\n============================"
				echo -e "\n알람을 종료하기 위해 q를 음속어를 위해서는 m을 누르세요"
				sound_alarm
			fi

			PREVIOUS_DOWN=$CURRENT_DOWN
			PREVIOUS_DATE=$CURRENT_DATE
		fi
	else
		echo "로그 파일이 없습니다"
		echo "1초 뒤 다시 실행합니다"
		sleep 1
		clear
		
	fi
}

#파일 변경 메인 실행
while true
do
	check_file_change
	sleep 1
	clear
done

