#!/bin/env bash
# config pacman include mirrorlist pacman.conf
# just copy resources/mirrorlist resources/pacman.conf

#

bakup_dir="$HOME/.bakup-lixu"
SHELL_FOLDER=$(dirname $(readlink -f "$0"))
root="$(dirname $SHELL_FOLDER)"
resources="$root/resources"
installer='yay -S'
dot_config="$HOME/.config"
systemd_user="$dot_config/systemd/user"
if [ ! -d $dot_config ]; then
    mkdir $dot_config
fi

if [ ! -d $systemd_user ]; then
    mkdir -p $systemd_user

fi

if [ ! -d $bakup_dir ]; then
    mkdir $bakup_dir
fi
if [ ! -d $HOME/.local/share/applications ]; then
    mkdir -p $HOME/.local/share/applications
fi
if [ ! -d $HOME/.local/share/fonts ]; then
    mkdir $HOME/.local/share/fonts
fi

function bakup_cp(){
    local target=$2
    local src=$1
    if [ -e $target ] || [ -h $target ]; then
        local name=$(basename $target)
        local bk="$bakup_dir/$name"
        if [ -e $bk ] || [ -h $bk ]; then

            bk="$bk-$(date "+%Y-%m-%d")"
        fi
        echo "mv $target  $bk"
        mv $target $bk
    fi
    echo "ln -s $src  $target"
    if [ -d $src ]; then

        ln -s $src $target
        if [ -L $target/$(basename $src) ]; then
            rm $target/$(basename $src)
        fi
        if [ -L $target/$(basename $target) ]; then
            rm $target/$(basename $target)
        fi

    elif [ -f $src ]; then
        ln -s $src $target
    fi

    # mv $(dirname $target)/$(basename $src) $target
}


declare -A override_files
override_files=(
    [resources/mirrorlist]="/etc/pacman.d/mirrorlist"
    [resources/pacman.conf]="/etc/pacman.conf"
    [resources/dot-xinitrc]="$HOME/.xinitrc"
    [resources/dot-xprofile]="$HOME/.xprofile"
    [resources/dot-pam_environment]="$HOME/.pam_environment"
    [conky]="$dot_config/conky"
    [polybar]="$dot_config/polybar"
    [xmonad]="$HOME/.xmonad"
    [i3]="$dot_config/i3"
    [alacritty]="$dot_config/alacritty"
    [picom]="$dot_config/picom"
    [resources/wallpaper]="$dot_config/wallpaper"
    [resources/feh.service]="$systemd_user/feh.service"
    [resources/emacs.service]="$systemd_user/emacs.service"
    [resources/feh.timer]="$systemd_user/feh.timer"
    [rofi]="$dot_config/rofi"
    [resources/dot-config/qv2ray]="$dot_config/qv2ray"
    [resources/emacsclient.desktop]="/usr/share/applications/emacsclient.desktop"
    [redshift]="$dot_config/redshift"
    [resources/emacsclient.desktop]="$HOME/.local/share/applications/emacsclient.desktop"
    [resources/dot_zprofile]="$HOME/.zprofile"
)
function override(){
    for src in ${!override_files[*]}
    do
        local target=${override_files[${src}]}
        local abs_src="$root/$src"
        echo "ovveride: $abs_src -> $target"
        bakup_cp $abs_src $target
    done
}

##########################
function config_aur(){
    sudo pacman -S archlinuxcn-keyring
    sudo pacman -Syyu
    sudo pacman -S yay
    # rm -rf /etc/pacman.d/gnupg
    # pacman-key --init
    # pacman-key --populate
    ##########
    sudo chmod u+r /etc/pacman.conf
    sudo chmod u+r /etc/pacman.d/mirrorlist
}
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
    fcitx5
    fcitx5-rime
    fcitx5-configtool
    fcitx5-gtk
    fcitx5-qt
    zsh
    sbt
    picom
    papirus-icon-theme
)
function install_common(){
    for pkg in ${pkgs[@]}
    do
        echo ":> $installer $pkg"
        $installer $pkg
    done
}
# install_common
#################################################
# config wm
#
##############################################

function config_wm(){
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
}

################ end config wm ##########

################ config vmware ##########
function config_vmware(){
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
}


#########################################

function config_zsh(){
    bash $root/scripts/oh-my-zsh.sh
}

function config_fonts(){
    $installer $(cat $root/scripts/fonts)
}
##
## auto login to v
#
# https://wiki.archlinux.org/index.php/Getty#Automatic_login_to_virtual_consoleoverride
# systemctl edit getty@tty1
# /etc/systemd/system/getty@tty1.service.d/override.conf
# [Service]
# ExecStart=
# ExecStart=-/usr/bin/agetty --autologin username --noclear %I $TERM
# config_zsh
sed -in "/ExecStart/d" $root/resources/feh.service
echo "ExecStart=/usr/bin/feh --recursive --bg-fill --randomize $HOME/.config/wallpaper" >> $systemd_user/feh.service
install_common
config_fonts
config_zsh
