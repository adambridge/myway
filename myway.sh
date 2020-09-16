#!/bin/bash

sudo apt-get install vim
cp ./vimrc ~/.vimrc
cp ./selected_editor ~/.selected_editor

cp ./bash_aliases ~/.bash_aliases
. ~/.bash_aliases
