set -o vi
OLDPATH="$PATH"
which powerline-daemon>/dev/null || export PATH=~/.local/bin:"$PATH"
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. ~/.local/lib/python3.*/site-packages/powerline/bindings/bash/powerline.sh
PATH="$OLDPATH"
