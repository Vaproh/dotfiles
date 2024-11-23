xcompmgr &

sxhkd -c "$HOME/.config/sxhkd/dwm-sxhkdrc" &

# only for laptops
# batsignal -m 5 -p -b -a dunst -e & 2>&1 | tee $HOME/.logs/batsignal.log

# copyq &
clipmenud &

mpd &

# /home/vaproh/.local/bin/scripts/new_look &

nitrogen --restore &
dunst &
