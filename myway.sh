#!/bin/bash
MYWAY_TAG="MYWAY-AUTO-INSTALL"
BASH_COMMENT="#"
VIM_COMMENT="\""

function reset_config() {
    local TGT=$1
    local TMP=$(mktemp /tmp/temp.XXXXXXXX)

    grep -v $MYWAY_TAG $TGT > $TMP
    case $? in
    0)  # At least one line returned
        cp $TMP $TGT && { echo $TGT restored. || echo Failed to restore $TGT; }
        ;;
    1)  # No lines but no error
        rm $TGT && { echo $TGT removed. || echo Failed to remove $TGT; }
        ;;
    2)  # Error
        echo Error restoring $TGT
        ;;
    esac
    rm $TMP
}

function update_config() {
    local SRC=$1
    local TGT=$2
    local COMMENT=$3
    local TMP=$(mktemp /tmp/temp.XXXXXXXX)
    local ORG=$(mktemp /tmp/temp.XXXXXXXX)
    
    [ -e $SRC ] || { echo Run ./mysay.sh from myway dir && exit 1; }
    [ -e $TGT ] && grep -v $MYWAY_TAG $TGT | tee $ORG > $TMP
    append_to_temp
    
    if is_bigger $TMP $ORG; then
        cp $TMP $TGT && { echo Successfully wrote $TGT. || echo Failed to write $TGT.; }
    elif diff $TMP $TGT; then
        echo Skipping $TGT, no changes required.
    else
        echo Skipping $TGT, new file would have been smaller than original \(error in script?\).
    fi
    rm $TMP
}

function append_to_temp() {
    MAX_WIDTH=$(wc -L $SRC | cut -d' ' -f1)
    PADDING=$(( $MAX_WIDTH + 8 ))
    while read LINE; do 
        printf "%-${PADDING}s\n" "$LINE";
    done < $SRC | sed "s/\$/$COMMENT $MYWAY_TAG/" >> $TMP
}

function is_bigger() {
    [ ! -s $2 ] && [ -s $1 ] && return 0
    [ `stat -c%s $1` -gt `stat -c%s $2` ] && return 0
    return 1
}

function git_config() {
    if ! git config --get $1 >/dev/null; then
        echo $2; read VAL; git config --global $1 "$VAL"
    fi
}

if [ ! -z $1 ]; then
    if [ $1 == "reset" ]; then
        reset_config ~/.vimrc
        reset_config ~/.bash_aliases
        reset_config ~/.selected_editor
        git config --global --unset user.name
        git config --global --unset user.email
        sudo apt-get purge vim
        sudo apt-get autoremove
        exit 0
    else
        echo usage: ./myway.sh [reset]
        exit 1
    fi
fi

# Vim
which vim &> /dev/null || sudo apt-get install vim
update_config ./vimrc ~/.vimrc $VIM_COMMENT

# Bash
update_config ./bash_aliases ~/.bash_aliases $BASH_COMMENT
update_config ./selected_editor ~/.selected_editor $BASH_COMMENT

# Disable bell? update_config ./inputrc /etc/inputrc

# Git
git_config user.name "Enter git user.name: Your Name (no quotes):"
git_config user.email "Enter git user.email: you@example.com:"

