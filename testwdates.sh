#!/bin/sh
BINL=$(realpath ".")
export BINL
mkdir -p TEST
ROOT=$(realpath "./TEST")
TMPATH="$(realpath ./dateset)"
export TMPATH
TMPDATEPATH=$(realpath ./dateset)
export TMPDATEPATH
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)


assert() {
    if [ "$1" != "$2" ]; then
        echo "${RED}Assertion failed: $1 != $2${NC}"
        echo "$3"
    else
        echo "${GREEN}OK${NC}"
    fi
}

supertouch(){
    mkdir -p "$(dirname "$1")"
    touch "$1"
}

moleadd(){
    if [ "$1" = "-g" ];then
        supertouch "$3"   
        $BINL/mole "$1" "$2" "$3"
    else
        supertouch "$1"
        $BINL/mole "$1"
    fi
}

setup(){
    rm -rf TEST
    mkdir -p TEST

    #init dates
    mkdir -p dateset
    rm dateset/tmp
    echo "Thu Feb 16 01:37:14 PM CET 2023" > dateset/tmp

    #end

    export EDITOR=touch
    export MOLE_RC=$ROOT/MOLE_RC
    touch "$MOLE_RC"

    DATE1=$(./testdate '+%Y-%m-%d')


    moleadd $ROOT/.ssh/config
    moleadd -g bash $ROOT/.bashrc
    moleadd $ROOT/.local/bin/./mole
    moleadd -g bash $ROOT/.bashrc                         # (D)
    moleadd $ROOT/.indent.pro
    moleadd $ROOT/.viminfo

    ./datesadday
    ./datesadday
    ./datesadday
    ./datesadday
    DATE2=$(./testdate '+%Y-%m-%d')

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

    ./datesadday
    ./datesadday
    ./datesadday
    DATE3=$(./testdate '+%Y-%m-%d')
    ./datesadday
    DATE4=$(./testdate '+%Y-%m-%d')

    moleadd -g git2 $ROOT/.gitconfig
    moleadd $ROOT/proj1/main.c
    moleadd $ROOT/.bashrc                                 # (E)
    moleadd $ROOT/.indent.pro
    moleadd $ROOT/.vimrc                                  # (B)

}

setup     
export EDITOR=echo
cd $ROOT/.ssh || exit
assert "$($BINL/mole)" "$ROOT/.ssh/known_hosts" "(odpovídá řádku A)"
assert "$($BINL/mole "$ROOT")" "$ROOT/.vimrc" "(odpovídá řádku B)"
assert "$($BINL/mole -g bash "$ROOT")" "$ROOT/.bash_profile" "(odpovídá řádku C)"
assert "$($BINL/mole -g bash -b "$DATE2" "$ROOT")" "$ROOT/.bashrc" "(odpovídá řádku D)"

cd $ROOT || exit
assert "$($BINL/mole -m)" "$ROOT/.bashrc" "(odpovídá řádku E)"
assert "$($BINL/mole -m -g git $ROOT/proj1/.git)" "$ROOT/proj1/.git/config" "(odpovídá řádku F; ve skupině git byl daný soubor editován jako jediný dvakrát, zbytek souborů jednou)"

export EDITOR=touch
$BINL/mole -m -g tst >> /dev/null
assert $? 1

$BINL/mole -a 2023-02-16 -b 2023-02-20 >> /dev/null
assert $? 1

cd .. || exit
setup
export EDITOR=echo
assert "$($BINL/mole list $ROOT)" '.bash_history: bash
.bash_profile: bash
.bashrc:       bash
.gitconfig:    git,git2
.indent.pro:   -
.viminfo:      -
.vimrc:        -' "Zobrazení seznamu editovaných souborů. 1. případ"
assert "$($BINL/mole list -g bash $ROOT)" '.bash_history: bash
.bash_profile: bash
.bashrc:       bash' "Zobrazení seznamu editovaných souborů. 2. případ"
assert "$($BINL/mole list -g project,project_readme $ROOT/proj1)" 'main.c:    project
README.md: project_readme
struct.c:  project
struct.h:  project' "Zobrazení seznamu editovaných souborů. 3. případ"
assert "$($BINL/mole list -b $DATE2 $ROOT)" '.bashrc:     bash
.indent.pro: -
.viminfo:    -' "Zobrazení seznamu editovaných souborů. 4. případ"
assert "$($BINL/mole list -a $DATE3 $ROOT)" '.bashrc:     -
.gitconfig:  git2
.indent.pro: -
.vimrc:      -' "Zobrazení seznamu editovaných souborů. 5. případ" # bug in example ".viminfo" was not edited ".vimrc" was and missing : after .gitconfig
assert "$($BINL/mole list -a $DATE1 -b $DATE4 -g bash $ROOT)" '.bash_history: bash
.bash_profile: bash' "Zobrazení seznamu editovaných souborů. 6. případ"
assert "$($BINL/mole list -a $DATE2 -b $DATE4 $ROOT)" "" "Zobrazení seznamu editovaných souborů. 7. případ"
assert "$($BINL/mole list -g grp1,grp2 $ROOT)" "" "Zobrazení seznamu editovaných souborů. 8. případ"

cd $ROOT || exit
$BINL/mole secret-log
TESTDATE=$(cat "$TMPDATEPATH/tmp" | tail -1)
TESTDATE=$(date -d "$TESTDATE" '+%Y-%m-%d_%H-%M-%S')
assert "$(bunzip2 -k --stdout $HOME/.mole/log_${USER}_$TESTDATE.bz2)" "$ROOT/.bash_history;2023-02-20_13-37-23
$ROOT/.bash_profile;2023-02-20_13-37-25
$ROOT/.bashrc;2023-02-16_13-37-17;2023-02-16_13-37-19;2023-02-24_13-37-40
$ROOT/.gitconfig;2023-02-20_13-37-24;2023-02-24_13-37-38
$ROOT/.indent.pro;2023-02-16_13-37-20;2023-02-24_13-37-41
$ROOT/.local/bin/mole;2023-02-16_13-37-18
$ROOT/proj1/.git/COMMIT_EDITMSG;2023-02-20_13-37-29;2023-02-20_13-37-30
$ROOT/proj1/.git/config;2023-02-20_13-37-28;2023-02-20_13-37-31
$ROOT/proj1/.git/info/exclude;2023-02-20_13-37-26
$ROOT/proj1/main.c;2023-02-20_13-37-32;2023-02-24_13-37-39
$ROOT/proj1/README.md;2023-02-20_13-37-35
$ROOT/proj1/struct.c;2023-02-20_13-37-33
$ROOT/proj1/struct.h;2023-02-20_13-37-34
$ROOT/.ssh/config;2023-02-16_13-37-16
$ROOT/.ssh/known_hosts;2023-02-20_13-37-27
$ROOT/.viminfo;2023-02-16_13-37-21
$ROOT/.vimrc;2023-02-24_13-37-42" "Vytvoření tajného logu případ 1."

$BINL/mole secret-log -b 2023-02-22 $ROOT/proj1 $ROOT/.ssh
TESTDATE=$(cat "$TMPDATEPATH/tmp" | tail -1)
TESTDATE=$(date -d "$TESTDATE" '+%Y-%m-%d_%H-%M-%S')
assert "$(bunzip2 -k --stdout $HOME/.mole/log_${USER}_$TESTDATE.bz2)" "$ROOT/proj1/main.c;2023-02-20_13-37-32
$ROOT/proj1/README.md;2023-02-20_13-37-35
$ROOT/proj1/struct.c;2023-02-20_13-37-33
$ROOT/proj1/struct.h;2023-02-20_13-37-34
$ROOT/.ssh/config;2023-02-16_13-37-16
$ROOT/.ssh/known_hosts;2023-02-20_13-37-27" "Vytvoření tajného logu případ 2."
rm -rf "$HOME/.mole"