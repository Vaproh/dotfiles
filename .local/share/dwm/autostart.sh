xcompmgr -o 0 & 2>&1 | tee $HOME/.logs/xcompmgr.log

sxhkd & 2>&1 | tee $HOME/.logs/sxhkd.log

spotifyd --no-daemon & 2>&1 | tee $HOME/.logs/spotifyd.log

# only for laptops
batsignal -m 5 -p -b -a dunst -e & 2>&1 | tee $HOME/.logs/batsignal.log

# copyq &
clipmenud &

mpd & 2>&1 | tee $HOME/.logs/mpd.log

/home/vaproh/.local/bin/scripts/new_look &
