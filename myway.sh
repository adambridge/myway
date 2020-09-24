#!/bin/bash

TAG="\" MYWAY-AUTO-INSTALL"

function are_different() {
    ! diff $1 $2
}

function append_config() {
    SRC=$1
    TGT=$2
    TMP=$(mktemp /tmp/temporary_file.XXXXXXXX)
    append_to_temp
    exit
    
    if are_different $TMP $TGT; then
        backup_target
        update_target
    fi

#   if [ -e $TGT.pre-myway ]; then
#       are_different $TMP $TGT && mv $TGT $TGT.prev && mv $TMP $TGT 
#   else
#       are_different $TMP $TGT && mv $TGT $TGT.original && mv $TMP $TGT 
#   fi
}

function append_to_temp() {
    grep -v "${TAG}$" $TGT > $TMP
    MAX_WIDTH=$(wc -L $SRC | cut -d' ' -f1)

    while read LINE; do 
        #printf "%-${MAX_WIDTH}s\n" $LINE;
        printf "%-70s\n" $LINE;
    done < $SRC >> $TMP
    # cat $SRC | sed "s/\$/ $TAG/" >> $TMP
}

function backup_target() {
    if [ ! -e $TGT.pre-myway ]; then
        cp $TGT TGT.pre-myway
    fi
}

sudo apt-get install vim

# Vim
append_config ./vimrc ~/.vimrc

#cp ./vimrc ~/.vimrc
#cp ./selected_editor ~/.selected_editor

##Bash
#cp ./bash_aliases ~/.bash_aliases
#. ~/.bash_aliases

#cp ./inputrc /etc/inputrc
