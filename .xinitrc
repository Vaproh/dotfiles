#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

dwmblocks & 2>&1 | tee $HOME/.logs/dwmblocks.log
/usr/bin/pipewire & 2>&1 | tee $HOME/.logs/pipewire.log
/usr/bin/pipewire-pulse & 2>&1 | tee $HOME/.logs/pipewire-pulse.log
/usr/bin/wireplumber & 2>&1 | tee $HOME/.logs/wireplumbler.log
exec dwm
