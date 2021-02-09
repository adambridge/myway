#!/bin/bash

URL=$(git config --get remote.origin.url)
if [ ${URL:0:4} = "http" ]; then
    REPO=${URL#http*://*github.com/}
    [ -z $REPO ] || git remote set-url origin git@github.com:$REPO
fi
