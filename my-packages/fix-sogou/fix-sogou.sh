#!/usr/bin/env bash

set -x

rm /etc/X11/Xsession.d/72sogoupinyin
rm /etc/X11/xinit/xinitrc.d/55-sogoupinyin.sh
rm /etc/xdg/autostart/fcitx-ui-sogou-qimpanel.desktop
