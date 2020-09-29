#!/bin/bash 
MYWAY_TAG="MYWAY-AUTO-INSTALL"
BASH_COMMENT="#"
VIM_COMMENT="\""

function process() {
    local SRC=$1
    local SRC_NAME=$(basename $SRC)
    local TGT=$2
    local COMMENT=$3
    local TMP=$(mktemp /tmp/$SRC_NAME.XXXXXXXX)
    
    [ -e $SRC ] || { echo Run ./mysay.sh from myway dir && exit 1; }
    [ -e $TGT ] && copy_target_to_temp
    append_to_temp
    
    if are_different $TMP $TGT; then
        # Maybe don't bother with backup, should be preseverved in file
        # Instead just be sure that replacement is larger
        if ! backup; then
            echo Failed to back up $TGT, skipping.
        else
            is_bigger $TMP $TGT && copy_temp_to_target
        fi
    else
        echo No changes required for $TGT, skipping.
    fi
    rm $TMP
}

function copy_target_to_temp() {
    grep -v $MYWAY_TAG $TGT > $TMP
}

function append_to_temp() {
    MAX_WIDTH=$(wc -L $SRC | cut -d' ' -f1)
    PADDING=$(( $MAX_WIDTH + 8 ))

    while read LINE; do 
        printf "%-${PADDING}s\n" "$LINE";
        #printf "%-70s\n" $LINE;
    done < $SRC | sed "s/\$/$COMMENT $MYWAY_TAG/" >> $TMP
}

function are_different() {
    [ ! -s $1 ] && [ ! -s $2 ] && return 1 # Both non-existent or zero size => not different, skip
    [ ! -s $1 ] && [ -s $2 ] && return 0 # One file non-existent or zero size => different
    [ -s $1 ] && [ ! -s $2 ] && return 0 # One file non-existent or zero size => different
    ! diff $1 $2 # diff returns 0 if files match => are_different returns 0 if files are different
}

function backup() {
    if [ -e $TGT ]; then
        if [ -e $TGT.pre-myway ]; then
            echo Keeping pre-existing backup.
        else
            echo Creating backup of $TGT as $TGT.pre-myway.
            grep -v $MYWAY_TAG $TGT > $TGT.pre-myway
        fi
    else
        # echo $TGT does not exist, it will be created now.
        touch $TGT.pre-myway-noexist
    fi
    confirm_backup
    return $?
}

function confirm_backup() {
    [ -e $TGT.pre-myway ] && [ -e $TGT ] && return 0
    [ -e $TGT.pre-myway-noexist ] && [ ! -e $TGT ] && return 0
    return 1
}

function is_bigger() {
    [ ! -s $2 ] && [ -s $1 ] && return 0
    [ `wc -l $1` -gt `wc -l $2` ] && [ `wc -c $1` -gt `wc -c $2` ] && return 0
    return 1
}

function copy_temp_to_target() {
    cp $TMP $TGT || echo Failed to write to $TGT.
}

function git_config() {
    if ! git config --get $1 >/dev/null; then
        echo $2
        read VAL
        git config --global $1 "$VAL"
    fi
}

which vim &> /dev/null || sudo apt-get install vim

# Vim
process ./vimrc ~/.vimrc $VIM_COMMENT

#process ./selected_editor ~/.selected_editor $BASH_COMMENT

# Bash
#cp ./bash_aliases ~/.bash_aliases
#. ~/.bash_aliases

#cp ./inputrc /etc/inputrc

# Git
git_config user.email "Enter git user.email: you@example.com:"
git_config user.name "Enter git user.name: Your Name (no quotes):"

