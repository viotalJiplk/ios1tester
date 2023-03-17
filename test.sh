#!/bin/sh
BINSLOZKA=$(realpath ".")
ROOTSLOZKA=$(realpath "./TEST")

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)

assert() {
    if [ "$1" != "$2" ]; then
        echo "${RED}Assertion failed: $1 != $2${NC}"
        #https://unix.stackexchange.com/questions/582796/using-the-diff-command-to-compare-two-s
        printf '%s\n' "$1" | od -c >tmpfile
        printf '%s\n' "$2" | od -c | diff tmpfile -
        rm -f tmpfile
    else
        echo "${GREEN}OK${NC}"
    fi
}

supertouch(){
    mkdir -p "$(dirname "$1")"
    touch "$1"
}

moleadd(){
    sleep 1
    if [ "$1" = "-g" ];then
        supertouch "$3"   
        $BINSLOZKA/mole "$1" "$2" "$3"
    else
        supertouch "$1"
        $BINSLOZKA/mole "$1"
    fi
}

export EDITOR=touch
export MOLE_RC=$ROOTSLOZKA/MOLE_RC
if [ -f "$MOLE_RC" ]; then
    echo "removing $MOLE_RC"
    rm "$MOLE_RC"
fi
supertouch "$MOLE_RC"
echo "Generating files. This may take some time"

sleep 1
DATE1=$(date '+%Y-%m-%d')
sleep 1
moleadd $ROOTSLOZKA/.ssh/config
moleadd -g bash $ROOTSLOZKA/.bashrc
moleadd $ROOTSLOZKA/.local/bin/mole
moleadd -g bash $ROOTSLOZKA/.bashrc                         # (D)
moleadd $ROOTSLOZKA/.indent.pro
moleadd $ROOTSLOZKA/.viminfo

sleep 1
DATE2=$(date '+%Y-%m-%d')
sleep 1
moleadd -g bash $ROOTSLOZKA/.bash_history
moleadd -g git $ROOTSLOZKA/.gitconfig
moleadd -g bash $ROOTSLOZKA/.bash_profile                   # (C)
moleadd -g git $ROOTSLOZKA/proj1/.git/info/exclude
moleadd $ROOTSLOZKA/.ssh/known_hosts                        # (A)
moleadd -g git $ROOTSLOZKA/proj1/.git/config
moleadd -g git $ROOTSLOZKA/proj1/.git/COMMIT_EDITMSG
moleadd $ROOTSLOZKA/proj1/.git/COMMIT_EDITMSG
moleadd -g git $ROOTSLOZKA/proj1/.git/config                # (F)
moleadd -g project $ROOTSLOZKA/proj1/main.c
moleadd -g project $ROOTSLOZKA/proj1/struct.c
moleadd -g project $ROOTSLOZKA/proj1/struct.h
moleadd -g project_readme $ROOTSLOZKA/proj1/README.md

sleep 1
DATE3=$(date '+%Y-%m-%d')
sleep 1
moleadd -g git2 $ROOTSLOZKA/.gitconfig
moleadd $ROOTSLOZKA/proj1/main.c
moleadd $ROOTSLOZKA/.bashrc                                 # (E)
moleadd $ROOTSLOZKA/.indent.pro
moleadd $ROOTSLOZKA/.vimrc                                  # (B)

echo "Files generated."
     
export EDITOR=echo
cd $ROOTSLOZKA/.ssh || exit
assert "$($BINSLOZKA/mole)" "$ROOTSLOZKA/.ssh/known_hosts" 
assert "$($BINSLOZKA/mole "$ROOTSLOZKA")" "$ROOTSLOZKA/.vimrc"
assert "$($BINSLOZKA/mole -g bash "$ROOTSLOZKA")" "$ROOTSLOZKA/.bash_profile"

cd $ROOTSLOZKA || exit
assert "$($BINSLOZKA/mole -m)" "$ROOTSLOZKA/.bashrc"
assert "$($BINSLOZKA/mole -m -g git $ROOTSLOZKA/proj1/.git)" "$ROOTSLOZKA/proj1/.git/config"

export EDITOR=touch
$BINSLOZKA/mole -m -g tst >> /dev/null
assert $? 1

$BINSLOZKA/mole -a 2023-02-16 -b 2023-02-20 >> /dev/null
assert $? 1

export EDITOR=echo
assert "$($BINSLOZKA/mole list $ROOTSLOZKA)" '.bash_history: bash
.bash_profile: bash
.bashrc:       bash
.gitconfig:    git,git2
.indent.pro:   -
.viminfo:      -
.vimrc:        -'

assert "$($BINSLOZKA/mole list -g bash $ROOTSLOZKA)" '.bash_history: bash
.bash_profile: bash
.bashrc:       bash'
assert "$($BINSLOZKA/mole list -g project,project_readme $ROOTSLOZKA/proj1)" 'main.c:    project
README.md: project_readme
struct.c:  project
struct.h:  project'
echo "You should use testwdates.sh! see README.md"