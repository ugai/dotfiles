#!/bin/sh
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

function is_dryrun() {
    [ $DRY_RUN -eq 1 ] && return $EXIT_SUCCESS || return $EXIT_FAILURE 
}

function no_subdir() {
    SUBDIR=
    echo "subdir="
}

function use_subdir() {
    SUBDIR=$1
    echo "subdir='$SUBDIR'"
    is_dryrun && mkdir -p ${HOME_DIR}/${SUBDIR}
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
create_link .mypy.ini
create_link .zshrc

use_subdir .config
create_link flake8

use_subdir .config/nvim
create_link init.vim

use_subdir .config/kitty
create_link kitty.conf

use_subdir .config/alacritty
create_link alacritty.yml

use_subdir .config/awesome
create_link rc.lua
create_link mytheme.lua
create_link autorun.sh
create_link reddit_kabegami.py
[ $DRY_RUN -eq 0 ] && (pushd ${HOME_DIR}/${SUBDIR} && [ -d battery-widget ] || git clone https://github.com/deficient/battery-widget.git; popd)
[ $DRY_RUN -eq 0 ] && (pushd ${HOME_DIR}/${SUBDIR} && [ -d volume-control ] || git clone https://github.com/deficient/volume-control.git; popd)
[ $DRY_RUN -eq 0 ] && (pushd ${HOME_DIR}/${SUBDIR} && [ -d lua-sputnikcolors ] || git clone https://github.com/tst2005/lua-sputnikcolors.git; popd)
[ $DRY_RUN -eq 0 ] && (pushd ${HOME_DIR}/${SUBDIR} && [ -d freedesktop ] || git clone https://github.com/lcpz/awesome-freedesktop.git freedesktop; popd)

