# Tester for "1. project from BUT FIT IOS 2022-23"
**It is not a production grade product**
## How to run
1. Put all files from this repo to directory with your mole shell file.
2. Set execution bit of files `testwdates.sh` `datesadday` `testdate`.
3. change all date commands in your mole file to `$BINSLOZKA/testdate`
(This will allow us test datefiltering)
or add branching:
```
if [ -z "${BINSLOZKA}" ]; then
    echo $(date)
else
    # for testing
    echo $($BINSLOZKA/testdate)
fi
```
If this does not work for you should read section about `testdate`.
## How to run without datefiltering testing 
**PLEASE USE VERSION WITH SUPPORT FOR DATEFILTERING.**
It has more tests and is faster.
1. Put test.sh file to directory with your mole shell file.
2. Set execution bit of file test.sh.
3. Run `./test.sh`

## What is testdate and how it works?
It returns date for tests instead of "real" date. It uses file `./dateset/tmp` to store last issued date and returns last issued date + 1 second. It works together with datesadday, which adds last date + 1 day to `./dateset/tmp`.
So you dont have to replace all occurrence of date in your script with it, but only ones, that you are writing to MOLE_RC file.