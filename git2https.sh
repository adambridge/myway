#!/bin/bash

URL=$(git config --get remote.origin.url)
if [ ${URL:0:10} = "git@github" ]; then
    REPO=${URL#git\@*github.com:}
    [ -z $REPO ] || git remote set-url origin https://github.com/$REPO
fi
