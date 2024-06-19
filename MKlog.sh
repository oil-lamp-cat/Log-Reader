#!/bin/bash

#테스트용 파일 (원한다면 변경 가능)
LOG_FILE="mlat.log"

#테스트용으로 만들어질 파일 (변경 할 이유 없음)
NEW_LOG_FILE="NEW_LOG_FILE.log"

# 파일 존재 확인 간소화
> "$NEW_LOG_FILE"

#이전 시간 저장	변수
PREV_TIME=""

#IFS 백업
PRE_IFS=$IFS

while IFS= read -r line; do

	# grep에서 ^를 통해 첫번 째 [] 만 꺼내왔다, tr로 []을 삭제하고 시간 부분만 저장
    TIME_STAMP=$(echo "$line" | grep -oP '^\[\d+\]' | tr -d '[]')

    if [[ -z "$TIME_STAMP" ]]; then
        continue
    fi

	#unix 시간 변경
    CURRENT_TIME=$(date -d "@$TIME_STAMP" "+%Y-%m-%d %H:%M:%S")

	#test용- 이 스크립트는 테스트 용도이다
	echo "============================="
	echo "이전 시간 : $PREV_TIME"
	echo "현재  시간 : $CURRENT_TIME"
	echo "============================="

    if [[ -n "$PREV_TIME" && "$PREV_TIME" != "$CURRENT_TIME" ]]; then
		echo "Time change detected"
        sleep 15
		clear
    fi

    echo "$line" >> "$NEW_LOG_FILE"

    PREV_TIME="$CURRENT_TIME"
done < "$LOG_FILE"

#IFS 원상복구
IFS=$PRE_IFS
echo "Log processing complete. Check the NEW_LOG_FILE.log for entries."