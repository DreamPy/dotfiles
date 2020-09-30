#!/bin/env bash
cfgs=(
    rofi
    alacritty
    i3
    polybar
    picom
)
for cfg in ${cfgs[@]}; do
    target=$HOME/.config/${cfg}
    echo ${target}
    sleep 1
    if [ -e ${target} ]
    then
        echo "rm -rf ${target}"
        rm -rf ${target}
    fi
    ln -s $HOME/manjaro/${cfg} ${target}
done
