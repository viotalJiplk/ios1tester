# Tester for "1. project from BUT FIT IOS 2022-23"
**It is not a production grade product**
## How to run
1. Put all files from this repo to directory with your mole shell file.
2. Set execution bit of files `testwdates.sh` `datesadday` `testdate`.
3. change all date commands in your mole file to `$BINL/testdate`
(This will allow us test datefiltering)
or add branching:
```
if [ -z "${BINL}" ]; then
    echo $(date)
else
    # for testing
    echo $($BINL/testdate)
fi
```
## How to run without datefiltering testing 
**PLEASE USE VERSION WITH SUPPORT FOR DATEFILTERING.**
It has more tests and is faster.
1. Put test.sh file to directory with your mole shell file.
2. Set execution bit of file test.sh.
3. Run `./test.sh`