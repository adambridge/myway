#!/bin/bash 
MYWAY_TAG="MYWAY-AUTO-INSTALL"
BASH_COMMENT="#"
VIM_COMMENT="\""

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
        if cp $TMP $TGT; then
            echo Successfully wrote $TGT.
        else
            echo Failed to write $TGT.
        fi
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

# Vim
which vim &> /dev/null || sudo apt-get install vim
update_config ./vimrc ~/.vimrc $VIM_COMMENT

# Bash
update_config ./bash_aliases ~/.bash_aliases $BASH_COMMENT
update_config ./selected_editor ~/.selected_editor $BASH_COMMENT

# Disable bell? update_config ./inputrc /etc/inputrc

# Git
git_config user.email "Enter git user.email: you@example.com:"
git_config user.name "Enter git user.name: Your Name (no quotes):"

