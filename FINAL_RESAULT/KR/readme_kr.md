# Log-Reader

이 스크립트는 **한글**로 구성되어있습니다

로그를 읽기 위한 쉘 스크립트

```
    へ 
 （• ˕ •マ 
    |､  ~ヽ         
    じしf_,)〳       made by LampCat
```
> 시작

`bash main.sh`를 통해 스크립트를 실행하실 수 있습니다.

`permission deny`가 나타나면 `chmod + x [sciprt name]`을 통해 권한을 부여할 수 있습니다.

이 스크립트를 처음 실행하면 변수를 변경할 수 있는 OPTION이라는 파일이 나옵니다.

> 스크립트가 하는 일

1. 로그에서 `DOWN` 및 `CRICTAL` 오류를 탐지할 수 있습니다
2. 확인하기 위해 `q`를 누를 때까지 알람을 계속 울립니다. 음소거의 경우 `m`을 누릅니다
3. 그게 다예요!

https://github.com/oil-lamp-cat/Log-Reader/assets/103806022/4c6c5716-ea6b-4719-8d39-9a9a553a711b

> OPTION에 관해

`LOG_PATH` : 읽을 로그에 대한 위치

`ALARM_REEPAT` : 알람 출력 주파수

`TEST_LOG_FILE` : 테스트 로그가 필요하지만 이미 작동하는 로그가 아닌 정적 로그를 사용하십시오

`RDLOG_REPATE` : **RDLOG_REPATE**초마다 확인하여 로그가 변경되었는지 확인

`TIME_FILTER_COUNT` : 파일 변경이 감지된 후 로그 시간 확인 **TIME_FILTER_COUNT**