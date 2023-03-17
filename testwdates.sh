#!/bin/sh
BINSLOZKA=$(realpath ".")
export BINSLOZKA
mkdir -p TEST
ROOTSLOZKA=$(realpath "./TEST")
mkdir -p "dateset"
TMPDATEPATH=$(realpath ./dateset)
export TMPDATEPATH
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)


assert() {
    if [ "$1" != "$2" ]; then
        echo "${RED}Assertion failed: $1 != $2${NC}"
        echo "$3"
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
    if [ "$1" = "-g" ];then
        supertouch "$3"   
        $BINSLOZKA/mole "$1" "$2" "$3"
    else
        supertouch "$1"
        $BINSLOZKA/mole "$1"
    fi
}

setup(){
    if [ -d "TEST" ]; then
        echo "removing folder TEST"
        rm -rf TEST
    fi
    mkdir -p TEST

    #init dates
    mkdir -p "$TMPDATEPATH"
    if [ -f "$TMPDATEPATH/tmp" ]; then
        echo "removing $TMPDATEPATH/tmp"
        rm "$TMPDATEPATH/tmp"
    fi
    echo "Thu Feb 16 01:37:14 PM CET 2023" > $TMPDATEPATH/tmp

    #end

    export EDITOR=touch
    export MOLE_RC=$ROOTSLOZKA/MOLE_RC
    touch "$MOLE_RC"

    DATE1=$(./testdate '+%Y-%m-%d')


    moleadd $ROOTSLOZKA/.ssh/config
    moleadd -g bash $ROOTSLOZKA/.bashrc
    moleadd $ROOTSLOZKA/.local/bin/mole
    moleadd -g bash $ROOTSLOZKA/.bashrc                         # (D)
    moleadd $ROOTSLOZKA/.indent.pro
    moleadd $ROOTSLOZKA/.viminfo

    ./datesadday
    ./datesadday
    ./datesadday
    ./datesadday
    DATE2=$(./testdate '+%Y-%m-%d')

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

    ./datesadday
    ./datesadday
    ./datesadday
    DATE3=$(./testdate '+%Y-%m-%d')
    ./datesadday
    DATE4=$(./testdate '+%Y-%m-%d')

    moleadd -g git2 $ROOTSLOZKA/.gitconfig
    moleadd $ROOTSLOZKA/proj1/main.c
    moleadd $ROOTSLOZKA/.bashrc                                 # (E)
    moleadd $ROOTSLOZKA/.indent.pro
    moleadd $ROOTSLOZKA/.vimrc                                  # (B)

}

setup     
export EDITOR=echo
cd $ROOTSLOZKA/.ssh || exit
assert "$($BINSLOZKA/mole)" "$ROOTSLOZKA/.ssh/known_hosts" "(odpovídá řádku A)"
assert "$($BINSLOZKA/mole "$ROOTSLOZKA")" "$ROOTSLOZKA/.vimrc" "(odpovídá řádku B)"
assert "$($BINSLOZKA/mole -g bash "$ROOTSLOZKA")" "$ROOTSLOZKA/.bash_profile" "(odpovídá řádku C)"
assert "$($BINSLOZKA/mole -g bash -b "$DATE2" "$ROOTSLOZKA")" "$ROOTSLOZKA/.bashrc" "(odpovídá řádku D)"

cd $ROOTSLOZKA || exit
assert "$($BINSLOZKA/mole -m)" "$ROOTSLOZKA/.bashrc" "(odpovídá řádku E)"
assert "$($BINSLOZKA/mole -m -g git $ROOTSLOZKA/proj1/.git)" "$ROOTSLOZKA/proj1/.git/config" "(odpovídá řádku F; ve skupině git byl daný soubor editován jako jediný dvakrát, zbytek souborů jednou)"

export EDITOR=touch
$BINSLOZKA/mole -m -g tst >> /dev/null
assert $? 1

$BINSLOZKA/mole -a 2023-02-16 -b 2023-02-20 >> /dev/null
assert $? 1

cd .. || exit
setup
export EDITOR=echo
assert "$($BINSLOZKA/mole list $ROOTSLOZKA)" '.bash_history: bash
.bash_profile: bash
.bashrc:       bash
.gitconfig:    git,git2
.indent.pro:   -
.viminfo:      -
.vimrc:        -' "Zobrazení seznamu editovaných souborů. 1. případ"
assert "$($BINSLOZKA/mole list -g bash $ROOTSLOZKA)" '.bash_history: bash
.bash_profile: bash
.bashrc:       bash' "Zobrazení seznamu editovaných souborů. 2. případ"
assert "$($BINSLOZKA/mole list -g project,project_readme $ROOTSLOZKA/proj1)" 'main.c:    project
README.md: project_readme
struct.c:  project
struct.h:  project' "Zobrazení seznamu editovaných souborů. 3. případ"
assert "$($BINSLOZKA/mole list -b $DATE2 $ROOTSLOZKA)" '.bashrc:     bash
.indent.pro: -
.viminfo:    -' "Zobrazení seznamu editovaných souborů. 4. případ"
assert "$($BINSLOZKA/mole list -a $DATE3 $ROOTSLOZKA)" '.bashrc:     -
.gitconfig:  git2
.indent.pro: -
.vimrc:      -' "Zobrazení seznamu editovaných souborů. 5. případ" # bug in example ".viminfo" was not edited ".vimrc" was and missing : after .gitconfig
assert "$($BINSLOZKA/mole list -a $DATE1 -b $DATE4 -g bash $ROOTSLOZKA)" '.bash_history: bash
.bash_profile: bash' "Zobrazení seznamu editovaných souborů. 6. případ"
assert "$($BINSLOZKA/mole list -a $DATE2 -b $DATE4 $ROOTSLOZKA)" "" "Zobrazení seznamu editovaných souborů. 7. případ"
assert "$($BINSLOZKA/mole list -g grp1,grp2 $ROOTSLOZKA)" "" "Zobrazení seznamu editovaných souborů. 8. případ"

cd $ROOTSLOZKA || exit
$BINSLOZKA/mole secret-log
USER=$(whoami)
TESTDATE=$(cat "$TMPDATEPATH/tmp" | tail -1)
TESTDATE=$(date -d "$TESTDATE" '+%Y-%m-%d_%H-%M-%S')
assert "$(bunzip2 -k --stdout $HOME/.mole/log_$USER\_$TESTDATE.bz2)" "$ROOTSLOZKA/.bash_history;2023-02-20_13-37-23
$ROOTSLOZKA/.bash_profile;2023-02-20_13-37-25
$ROOTSLOZKA/.bashrc;2023-02-16_13-37-17;2023-02-16_13-37-19;2023-02-24_13-37-40
$ROOTSLOZKA/.gitconfig;2023-02-20_13-37-24;2023-02-24_13-37-38
$ROOTSLOZKA/.indent.pro;2023-02-16_13-37-20;2023-02-24_13-37-41
$ROOTSLOZKA/.local/bin/mole;2023-02-16_13-37-18
$ROOTSLOZKA/proj1/.git/COMMIT_EDITMSG;2023-02-20_13-37-29;2023-02-20_13-37-30
$ROOTSLOZKA/proj1/.git/config;2023-02-20_13-37-28;2023-02-20_13-37-31
$ROOTSLOZKA/proj1/.git/info/exclude;2023-02-20_13-37-26
$ROOTSLOZKA/proj1/main.c;2023-02-20_13-37-32;2023-02-24_13-37-39
$ROOTSLOZKA/proj1/README.md;2023-02-20_13-37-35
$ROOTSLOZKA/proj1/struct.c;2023-02-20_13-37-33
$ROOTSLOZKA/proj1/struct.h;2023-02-20_13-37-34
$ROOTSLOZKA/.ssh/config;2023-02-16_13-37-16
$ROOTSLOZKA/.ssh/known_hosts;2023-02-20_13-37-27
$ROOTSLOZKA/.viminfo;2023-02-16_13-37-21
$ROOTSLOZKA/.vimrc;2023-02-24_13-37-42" "Vytvoření tajného logu případ 1."

$BINSLOZKA/mole secret-log -b 2023-02-22 $ROOTSLOZKA/proj1 $ROOTSLOZKA/.ssh
TESTDATE=$(cat "$TMPDATEPATH/tmp" | tail -1)
TESTDATE=$(date -d "$TESTDATE" '+%Y-%m-%d_%H-%M-%S')
assert "$(bunzip2 -k --stdout $HOME/.mole/log_$USER\_$TESTDATE.bz2)" "$ROOTSLOZKA/proj1/main.c;2023-02-20_13-37-32
$ROOTSLOZKA/proj1/README.md;2023-02-20_13-37-35
$ROOTSLOZKA/proj1/struct.c;2023-02-20_13-37-33
$ROOTSLOZKA/proj1/struct.h;2023-02-20_13-37-34
$ROOTSLOZKA/.ssh/config;2023-02-16_13-37-16
$ROOTSLOZKA/.ssh/known_hosts;2023-02-20_13-37-27" "Vytvoření tajného logu případ 2."
if [ -d "$HOME/.mole" ]; then
    echo "removing $HOME/.mole"
    rm -rf "$HOME/.mole"
fi