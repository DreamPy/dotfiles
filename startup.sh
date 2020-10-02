#!/bin/env bash
fcitx5 &
feh --recursive --bg-fill --randomize $HOME/.config/wallpaper
systemctl start --user feh.timer
# picom --experimental-backend
picom -b
bash $HOME/.config/polybar/launch.sh

$VMWARE vmware-user
