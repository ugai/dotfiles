#!/bin/sh

function run {
    if ! pgrep $1 ; then
        $@&
    fi
}

#run light-locker
run fcitx
run nm-applet
run blueman-applet
run pamac-tray
#run compton
#run steam -silent
