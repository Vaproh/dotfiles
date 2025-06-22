#! /bin/sh

# Detect whether we're running on Xorg or Wayland
if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    suspend="systemctl suspend && hyprlock"
    lock="hyprlock"
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    suspend="systemctl suspend && swaylock"
    lock="swaylock"
else
    suspend="systemctl suspend && i3lock-fancy"
    lock="i3lock-fancy"
fi

# special method for loggin out :(
if [ "$DESKTOP_SESSION" = "i3" ]; then
    logout="killall i3"
  elif [ "$DESKTOP_SESSION" = "hyprland" ]; then
    logout="killall Hyprland"
  elif [ "$DESKTOP_SESSION" = "sway" ]; then
    logout="killall sway"
  else
    logout="loginctl terminate-user $USER"
fi

# Present the power menu dependin od display server

# if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
#     chosen=$(printf "Log Out\nSuspend\nRestart\nPower OFF" |  fuzzel --dmenu -l 4 --width 10 --anchor top-left -p "menu : ")
#   elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
#     chosen=$(printf "Log Out\nSuspend\nRestart\nPower OFF" | rofi -dmenu -i -theme-str '@import "~/.config/rofi/powermenu.rasi"')
# fi

chosen=$(printf "Lock\nLog Out\nSuspend\nReboot\nShutdown" | rofi -dmenu -i -l 5 -p ">=" -font "JetBrains Mono NF 16" -theme-str 'window {width: 7em;} listview {lines: 5;}')
printf $chosen
# Perform the action based on user choice
case "$chosen" in
    "Lock") $lock ;;
    "Log Out") $logout ;;
    "Suspend") eval $suspend ;;
    "Reboot") systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
    *) exit 1 ;;
esac
