#!/bin/sh
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

dbus-update-activation-environment --systemd \
    WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=mango \
    GTK_IM_MODULE QT_IM_MODULE XMODIFIERS
systemctl --user import-environment \
    WAYLAND_DISPLAY XDG_CURRENT_DESKTOP \
    GTK_IM_MODULE QT_IM_MODULE XMODIFIERS

swaybg -i ~/Wallpapers/wallpaper.jpg -m fill &
waybar &
mako &
fcitx5 -d --replace &
mpris-proxy &
/usr/lib/polkit-kde-authentication-agent-1 &
/usr/lib/xdg-desktop-portal-gtk &
systemctl --user start mpd mpd-mpris
