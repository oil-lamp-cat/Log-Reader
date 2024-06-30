# Log-Reader

This script is made in **Korean**

shell script for log reading

```
    へ 
 （• ˕ •マ 
    |､  ~ヽ         
    じしf_,)〳       made by LampCat
```
> start

`bash main.sh` to start script.

If `permission denied` appears, you can give permission through `chmod +x [sciprtname]`.

Once you run this script for the first time, you'll get a file called OPTION, where you can change the variables.

> what this can do

1. It can catch `DOWN` and `CRITICAL` Errors in log
2. Keep ringing the alarm until we press `q` to confirm, for mute press `m`
3. And thats all!

https://github.com/oil-lamp-cat/Log-Reader/assets/103806022/f56072cd-a305-4bb6-bd25-a536800f7d9c

> about OPTION

`LOG_PATH` : Location about log to read

`ALARM_REPEAT` : Frequency of the alarm output

`TEST_LOG_FILE` : For test LOG needed, But please use static logs not the thing already work

`RDLOG_REPEAT` : Check every **RDLOG_REPEAT**seconds to see if the log has changed

`TIME_FILTER_COUNT` : Check log times after file changes are detected **TIME_FILTER_COUNT**