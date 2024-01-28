#!/bin/bash
EXIT_SUCCESS=0
EXIT_FAILURE=1

DRY_RUN=0
REPO_DIR=$PWD
HOME_DIR=$HOME

if [ "$1" = "-h" ]; then
    echo "Usage: install.sh [-h] [--dry-run]"
    exit $EXIT_FAILURE
elif [ "$1" = "--dry-run" ]; then
    DRY_RUN=1
fi

echo "'$REPO_DIR' -> '$HOME_DIR'"
echo -n "Continue? [y/N]: "
read RET

if [ "$RET" != "y" ]; then
    echo "Cancelled."
    exit $EXIT_FAILURE
fi

function no_subdir() {
    SUBDIR=
    echo "subdir="
}

function use_subdir() {
    SUBDIR=$1
    echo "subdir='$SUBDIR'"
    [ $DRY_RUN -eq 0 ] && mkdir -p ${HOME_DIR}/${SUBDIR}
}

function create_link () {
    local SRC=$(realpath -sm "${REPO_DIR}/${SUBDIR}/$1")
    local DST=$(realpath -sm "${HOME_DIR}/${SUBDIR}/$1")
    echo "link: '$SRC' -> '$DST'"
    [ $DRY_RUN -eq 0 ] && ln -fs $SRC $DST
}

no_subdir
create_link .Xresources
create_link .bashrc
create_link .zshrc

use_subdir .config/nvim
create_link init.vim

use_subdir .config/mpv
create_link mpv.conf
