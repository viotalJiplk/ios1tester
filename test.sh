#!/bin/sh
BINL=$(realpath ".")
ROOT=$(realpath "./TEST")

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)

assert() {
    if [ "$1" != "$2" ]; then
        echo "${RED}Assertion failed: $1 != $2${NC}"
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
        $BINL/mole "$1" "$2" "$3"
    else
        supertouch "$1"
        $BINL/mole "$1"
    fi
}

export EDITOR=touch
export MOLE_RC=$ROOT/MOLE_RC
rm "$MOLE_RC"
supertouch "$MOLE_RC"
echo "Generating files. This may take some time"

sleep 1
DATE1=$(date '+%Y-%m-%d')
sleep 1
moleadd $ROOT/.ssh/config
moleadd -g bash $ROOT/.bashrc
moleadd $ROOT/.local/bin/./mole
moleadd -g bash $ROOT/.bashrc                         # (D)
moleadd $ROOT/.indent.pro
moleadd $ROOT/.viminfo

sleep 1
DATE2=$(date '+%Y-%m-%d')
sleep 1
moleadd -g bash $ROOT/.bash_history
moleadd -g git $ROOT/.gitconfig
moleadd -g bash $ROOT/.bash_profile                   # (C)
moleadd -g git $ROOT/proj1/.git/info/exclude
moleadd $ROOT/.ssh/known_hosts                        # (A)
moleadd -g git $ROOT/proj1/.git/config
moleadd -g git $ROOT/proj1/.git/COMMIT_EDITMSG
moleadd $ROOT/proj1/.git/COMMIT_EDITMSG
moleadd -g git $ROOT/proj1/.git/config                # (F)
moleadd -g project $ROOT/proj1/main.c
moleadd -g project $ROOT/proj1/struct.c
moleadd -g project $ROOT/proj1/struct.h
moleadd -g project_readme $ROOT/proj1/README.md

sleep 1
DATE3=$(date '+%Y-%m-%d')
sleep 1
moleadd -g git2 $ROOT/.gitconfig
moleadd $ROOT/proj1/main.c
moleadd $ROOT/.bashrc                                 # (E)
moleadd $ROOT/.indent.pro
moleadd $ROOT/.vimrc                                  # (B)

echo "Files generated."
     
export EDITOR=echo
cd $ROOT/.ssh || exit
assert "$($BINL/mole)" "$ROOT/.ssh/known_hosts" 
assert "$($BINL/mole "$ROOT")" "$ROOT/.vimrc"
assert "$($BINL/mole -g bash "$ROOT")" "$ROOT/.bash_profile"

cd $ROOT || exit
assert "$($BINL/mole -m)" "$ROOT/.bashrc"
assert "$($BINL/mole -m -g git $ROOT/proj1/.git)" "$ROOT/proj1/.git/config"

export EDITOR=touch
$BINL/mole -m -g tst >> /dev/null
assert $? 1

$BINL/mole -a 2023-02-16 -b 2023-02-20 >> /dev/null
assert $? 1

export EDITOR=echo
assert "$($BINL/mole list $ROOT)" '.bash_history: bash
.bash_profile: bash
.bashrc:       bash
.gitconfig:    git,git2
.indent.pro:   -
.viminfo:      -
.vimrc:        -'
assert "$($BINL/mole list -g bash $ROOT)" '.bash_history: bash
.bash_profile: bash
.bashrc:       bash'
assert "$($BINL/mole list -g project,project_readme $ROOT/proj1)" 'main.c:    project
README.md: project_readme
struct.c:  project
struct.h:  project'
cd ..
$BINL/mole secret-log
echo ""
$BINL/mole secret-log $ROOT/proj1 $ROOT/.ssh