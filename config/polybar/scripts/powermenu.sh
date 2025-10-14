#!/usr/bin/env sh

OPTIONS="Shutdown\nReboot\nSuspend\nLogout"

CMD=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Power Menu:")

case "$CMD" in
Shutdown) systemctl poweroff ;;
Reboot) systemctl reboot ;;
Suspend) systemctl suspend ;;
Logout) i3-msg exit ;;
*) exit 1 ;;
esac
