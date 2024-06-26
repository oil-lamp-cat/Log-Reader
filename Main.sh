#!/bin/bash

usage()
{
    echo '
    <options>
    -t : 테스트 스크립트 실행
    '
}

bash ./MKlog.sh
sleep 2
bash ./ReadLog.sh