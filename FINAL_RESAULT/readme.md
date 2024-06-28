로그 읽기 스크립트 ReadLog입니다

    へ 
 （• ˕ •マ 
    |､  ~ヽ         
    じしf_,)〳       made by LampCat

> 실행

`main.sh`를 실행시켜 주시면 됩니다

만약 permission denied가 뜬다면 `chmod +x '스크립트'`를 통해 권한을 주시면 됩니다

> OPTION에 대한 설명

처음 main.sh를 실행시키게 되면 OPTION을 만들게 됩니다

`OPTION`파일에서는 알람 빈도수, 로그 파일 위치를 변경하실 수 있습니다

`LOG_PATH`에는 테스트가 아닌 실제 읽고자 하는 로그의 위치를 넣으시면 됩니다

`ALARM_REPEAT`은 CRITICAL 또는 DOWN이 감지되었을 때 비프음을 계속해서 내게 될 것인데 그 때의 빈도수를 조절 할 수 있습니다

`TEST_LOG_FILE`에 테스트 하고 싶은 로그 파일을 넣으면 됩니다

`RDLOG_REPEAT` 로그를 읽을 빈도수 입니다