#!/bin/bash
MYWAY_TAG="MYWAY-AUTO-INSTALL"
BASH_COMMENT="#"
VIM_COMMENT="\""
GIT_SSH_REMINDER_YN="n"

function restore_config() {
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

function restore() {
    restore_config ~/.vimrc
    restore_config ~/.bash_aliases
    restore_config ~/.bashrc
    restore_config ~/.selected_editor
    restore_config ~/.zprofile
    restore_config ~/.zshrc
    git config --global --unset user.name
    git config --global --unset user.email
}

function first_time_setup() {
    # Create config with path to script
    mkdir ~/.myway
    SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    echo SCRIPTDIR=$SCRIPTDIR > ~/.myway/myway.config

    # Create user bin dir with link to script
    [ -d ~/bin ] || mkdir ~/bin
    ln -fs $SCRIPTDIR/myway.sh ~/bin/myway
}

function build_vim() {
    sudo apt-get install -y libncurses-dev
    [ -d ~/projects ] || mkdir ~/projects
    PREVDIR=$(pwd)
    cd ~/projects
    git clone https://github.com/vim/vim.git 
    cd vim
    ./configure --enable-python3interp
    make
    sudo make install
    cd $PREVDIR
}

function install_docker() {
    if [ ! -z $WSL_DISTRO_NAME ]; then
        DISTRO=${WSL_DISTRO_NAME,,}
        if [ $DISTRO = "debian" ]; then
            sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
            sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
        fi
    fi

    if [ ! -z $DISTRO ]; then
        sudo apt-get remove docker docker-engine docker.io containerd runc
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common
        curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo apt-key add -
        sudo apt-key fingerprint 0EBFCD88
        sudo add-apt-repository \
           "deb [arch=amd64] https://download.docker.com/linux/$DISTRO \
           $(lsb_release -cs) \
           stable"
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo update-rc.d docker enable
        sudo service docker start
        sudo usermod -aG docker $USER
        docker run hello-world
    else
        echo Not sure which distro this is, skipping docker install
    fi
}

function git_setup() {
    git_config user.name "Enter git user.name: Your Name (no quotes):"
    git_config user.email "Enter git user.email: you@example.com:"
    if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -b 4096 -C $(git config --get user.email) -f ~/.ssh/id_rsa
        eval "$(ssh-agent -s)"
        ssh-add  ~/.ssh/id_rsa
        GIT_SSH_REMINDER_YN="y"
    fi
}

function main() {
    # Create myway config if running for first time
    if [ ! -d ~/.myway ]; then
        first_time_setup
    fi

    # Read myway config and go to myway script dir
    ORIGINALDIR=$(pwd)
    . ~/.myway/myway.config || { echo myway config not found && exit 1; }
    cd $SCRIPTDIR

    # Apt update/upgrade
    sudo apt update
    sudo apt -y upgrade
    sudo apt autoremove

    # Restore files altered by myway script?
    if [ ! -z $1 ]; then
        if [ $1 == "restore" ]; then
            restore
            exit 0
        else
            echo usage: ./myway.sh [restore]
            exit 1
        fi
    fi

    # Vim
    read -p "Compile vim from source (y/n)? " COMPILE_VIM_YN
    if [ $COMPILE_VIM_YN = "y" ]; then
        [ $(which vim) = "/usr/local/bin/vim" ] || build_vim
    fi
    # which vim &> /dev/null || sudo apt-get install -y vim
    update_config ./vimrc ~/.vimrc          # vimrc has " and # comment styles so provide directly in ./vimrc

    # Python pip
    sudo apt-get install -y python3-pip

    # Powerline
    pip3 install powerline-status

    # Bash
    update_config ./bashrc ~/.bashrc $BASH_COMMENT
    update_config ./bash_aliases ~/.bash_aliases $BASH_COMMENT
    update_config ./selected_editor ~/.selected_editor $BASH_COMMENT

    # Zsh
    which zsh &> /dev/null || sudo apt-get install -y zsh
    update_config ./zshrc ~/.zshrc $BASH_COMMENT
    update_config ./zprofile ~/.zprofile $BASH_COMMENT
    sudo usermod --shell $(which zsh) $USER

    # Disable bell? update_config $SCRIPTDIR/inputrc /etc/inputrc

    # Git
    git_setup

    # Man
    which man &> /dev/null || sudo apt-get install -y man-db

    # Docker
    read -p "Install docker (y/n)? " DOCKER_YN
    if [ $DOCKER_YN = "y" ] && ! which docker &> /dev/null; then
        install_docker
    fi

    # Return to original dir
    cd $ORIGINALDIR
    if [ $GIT_SSH_REMINDER_YN = "y" ]; then
        echo A new ssh key was created, copy the below and upload it to github
        cat ~/.ssh/id_rsa.pub
    fi

    exec zsh -l
}

main "$@"
