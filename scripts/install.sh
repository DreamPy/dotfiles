#!/bin/env bash

# set mirrors
set_mirror="sudo pacman-mirrors -i -c China -m rank"
echo "Exec: ${set_mirror}"
# exec set_mirror

# add archilinuxcn
add_content="[archlinuxcn]\nSigLevel = Optional TrustedOnly\nServer = https://mirrors.sjtug.sjtu.edu.cn/archlinux-cn/$arch"

grep "\[archlinuxcn\]" /etc/pacman.conf || sudo echo -e ${add_content} >> /etc/pacman.conf

# sudo pacman -Syyu
# install packages

pkgs=(
    ttf-jetbrains-mono
    yay
    emacs
    archlinuxcn-keyring
    rofi
    feh
    variety
    alacritty
    polybar
    i3
    fish
    ranger
    proxychains
    fcitx-rime
    fcitx-im
    fcitx-configtool
    network-manager-applet
    picom
)
# fix start error no color define
xrdb /dev/null
install="sudo pacman -S ${pkgs[@]}"
echo "Exec: ${install}"
exec ${install}
pam="${HOME}/.pam_environment"
config_fcitx="export GTK_IM_MODULE=fcitx\nexport QT_IM_MODULE=fcitx\nexport XMODIFIERS=\"@im=fcitx\"
"
if [ !  -e ${pam} ]
then
    echo "config fcitx"
    echo -e ${config_fcitx} > ${pam}
fi
