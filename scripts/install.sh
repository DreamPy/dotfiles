#!/bin/env bash
# config pacman include mirrorlist pacman.conf
# just copy resources/mirrorlist resources/pacman.conf

#

bakup_dir="$HOME/.bakup-lixu"
SHELL_FOLDER=$(dirname $(readlink -f "$0"))
root="$(dirname $SHELL_FOLDER)"
resources="$root/resources"
installer='yay -S'
function bakup_cp(){
    local target=$2
    local src=$1
    if [ -d "$target" ]; then
        local bk="$bakup_dir/$target"
        if [ -d $(basename "$bakup_dir/$target") ]; then

            bk="$bakup_dir/$target-$(date "+%Y-%m-%d")"
        fi
        echo "mv $target to $bk"

    fi
    echo "cp $src to $target"
}
declare -A override_files
override_files=(
    [mirrorlist]="/etc/pacman.d/mirrorlist"
    [pacman.conf]="/etc/pacman.conf"
    [dot-xinitrc]="$HOME/.xinitrc"
    [dot-xprofile]="$HOME/.xprofile"
    [dot-pam_environment]="$HOME/.pam_environment"
)
function ovveride(){
    for src in ${!override_files[*]}
    do
        local target=${override_files[${src}]}
        local abs_src="$resources/$src"
        echo "ovveride: $abs_src -> $target"
        bakup_cp $abs_src $target
    done
}
echo "Begin ovveride some configs"
ovveride
echo "End ovveride"
##########################

pacman -S archlinxcn-keyring
pacman -Syyu
pacman -S yay
# rm -rf /etc/pacman.d/gnupg
# pacman-key --init
# pacman-key --populate
##########
pkgs=(
    v2ray
    qv2ray
    rofi
    feh
    alacritty
    polybar
    conky-cairo
    ranger
    proxychains
    fcitx
    fcitx5-rime
    fcitx5-configtool
    fcitx5-gtk
    fcitx5-qt
    fcitx5-qt4-git
    zsh
    sbt
)

for pkg in ${pkgs[@]}
do
    echo "$installer $pkg"
done
#################################################
# config wm
#
##############################################


read -p \
$'use wm
1)xmonad 2)i3
default=all:>' wm
echo "$wm---"
if [ -z $wm ]; then
    wm="all"
fi

xmonad=(
    xmonad
    xmonad-contrib
)

i3=(
    i3-gaps
    i3blocks
    i3lock-fancy-git
    i3status
)
wm_pkgs=(${xmonad[@]} ${i3[@]})
if [ $wm = "all" ]; then
    echo "select all"
    for pkg in ${wm_pkgs[@]}
    do
        echo "$installer $pkg"
    done


fi

if [ $wm = "1" ]; then
    echo "select xmonad"
fi

if [ $wm = "2" ]; then
    echo "select i3"
fi
################ end config wm ##########

################ config vmware ##########

vmware_pkgs=(
    open-vm-tools
    gtkmm3
)

read -p "config open vmware tools ?Y/n:" vmware
if [ -z $vmware ]; then
    vmware="Y"
fi

if [ $vmware = "Y" ]; then

    echo "install packages"
    for pkg in ${vmware_pkgs[@]}
    do
        echo "$installer $pkg"
    done
    ehco "enable systemd unit"
    echo "systemctl enable vmtoolsd"
    echo "systemctl enable "
fi
