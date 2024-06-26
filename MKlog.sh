#!/bin/bash

#테스트용 파일 (원한다면 변경 가능)
LOG_FILE="mlat.log"

#테스트용으로 만들어질 파일 (변경 할 이유 없음)
NEW_LOG_FILE="NEW_LOG_FILE.log"

# 파일 존재 확인 간소화
> "$NEW_LOG_FILE"

#이전 시간 저장	변수
PREV_TIME=""

#저장용 배열
LINE_ARRAY=""

while read -r line; do

	# grep에서 ^를 통해 첫번 째 [] 만 꺼내왔다, tr로 []을 삭제하고 시간 부분만 저장
    TIME_STAMP=$(echo "$line" | grep -oP '^\[\d+\]' | tr -d '[]')

    if [[ -z "$TIME_STAMP" ]]; then
        continue
    fi

	#unix 시간 변경
    CURRENT_TIME=$(date -d "@$TIME_STAMP" "+%Y-%m-%d %H:%M:%S")

	#test용 출력
	#echo "============================="
	#echo "이전 시간 : $PREV_TIME"
	#echo "현재  시간 : $CURRENT_TIME"
	#echo "============================="

    #시간변경 감지 후 새로운 로그 추가
    if [[ -n "$PREV_TIME" && "$PREV_TIME" != "$CURRENT_TIME" ]]; then
		echo "Time change detected"
        #파일로 한번에 저장 (\n이 존재하기에 -e를 이용)
        echo -e "$LINE_ARRAY" >> "$NEW_LOG_FILE"
        #배열 초기화
        LINE_ARRAY=""
        #대기 시간
        sleep 15 #$(( $PREV_TIME - $CURRENT_TIME +%S )) #으로 실제 테스트를 진행할 수 있다
		clear
    fi

    #배열 추가
    if [[ -n "$LINE_ARRAY" ]]; then
        LINE_ARRAY+="\n$line"
    else
        LINE_ARRAY="$line"
    fi

    #echo "$line" >> "$NEW_LOG_FILE"
    PREV_TIME="$CURRENT_TIME"
done < "$LOG_FILE"

echo "모든 테스트 로그가 종료되었습니다"