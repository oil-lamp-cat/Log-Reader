#!/bin/bash

OPTION_FOLDER_PATH="./OPTION"
OPTIONS=":th?"
OPTION_TRUE=0
USER_ID=$USER
HOST_NAME=$(hostname)

if [ ! -f "$OPTION_FOLDER_PATH" ]; then
    clear
    echo "옵션 파일이 존재하지 않습니다."
    touch "$OPTION_FOLDER_PATH"
    echo "#대괄호를 삭제하지 말고 안에 넣기!
#문제 발생시 : https://oil-lamp-cat.github.io/

#이곳에 읽고자 하는 log의 위치를 넣으세요
LOG_PATH : [./mlat.log]

#알람 출력 빈도입니다 - 기본 0.3s
ALARM_REPEAT : [0.3]

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
    " > "$OPTION_FOLDER_PATH"
    echo "./OPTION 파일을 생성하였으니 확인하고 설정을 끝낸 뒤 다시 찾아와주세요~"
    exit 1
fi

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
        echo "invalid option"
        usage
        exit 1;;
    t) 
        echo "테스트 스크립트 실행"
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

    #모든 스크립트는 ctrl+c를 눌러 빠져나올 수 있습니다#

    1. 테스트 스크립트 실행 (MKlog.sh, ReadLog.sh) - 새로운 tab이 열릴 것입니다
    2. 로그 읽는 스크립트 실행 (ReadLog.sh) - DOWN만 감지
    3. 로그 읽는 스크립트 전체 감지 모드로 실행 (ReadLog.sh) - DOWN, CRITICAL 감지
    4. 특정 단어가 포함된 DOWN, CRITICAL 감지
    5. 도움이 필요하다면 이곳으로
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
            echo "잘못된 입력입니다"
            exit 1
        ;;
    esac
fi