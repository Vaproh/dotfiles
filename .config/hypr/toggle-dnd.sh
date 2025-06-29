#!/bin/bash

STATE_FILE="/tmp/swaync-dnd.lock"
ICON_ON="notification-disabled-symbolic"
ICON_OFF="notification-symbolic"
DURATION=1800  # 30 minutes
TIMEOUT=5000   # Notification timeout in ms

if [[ -f "$STATE_FILE" ]]; then
    swaync-client -d
    notify-send -u critical -t $TIMEOUT -i "$ICON_OFF" "󰂛 Do Not Disturb" "🔔 DND is now OFF. Notifications are enabled."
    rm -f "$STATE_FILE"
else
    swaync-client -d
    notify-send -u critical -t $TIMEOUT -i "$ICON_ON" "󰂛 Do Not Disturb" "🔕 DND is now ON. Notifications will be muted for 30 minutes."
    touch "$STATE_FILE"
    (
        sleep "$DURATION"
        swaync-client -d
        notify-send -u critical -t $TIMEOUT -i "$ICON_OFF" "󰂛 Do Not Disturb" "⏰ DND timed out after 30 minutes."
        rm -f "$STATE_FILE"
    ) &
fi

